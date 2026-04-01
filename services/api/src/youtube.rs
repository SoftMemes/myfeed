use chrono::{DateTime, Duration, Utc};
use serde::Deserialize;
use tracing::error;

const BASE_URL: &str = "https://www.googleapis.com/youtube/v3";

// ---------------------------------------------------------------------------
// Public types
// ---------------------------------------------------------------------------

#[derive(Clone)]
pub struct YouTubeClient {
    http: reqwest::Client,
    api_key: String,
}

pub struct YouTubeChannel {
    pub channel_id: String,
    pub title: String,
    pub description: String,
    pub image_url: String,
    pub subscriber_count: Option<u64>,
}

pub struct YouTubeVideo {
    pub video_id: String,
    pub title: String,
    pub description: String,
    pub image_url: String,
    pub published_at: String, // ISO 8601
}

// ---------------------------------------------------------------------------
// Error type
// ---------------------------------------------------------------------------

pub enum YouTubeError {
    QuotaExceeded,
    NotFound,
    Network(reqwest::Error),
    Unexpected(String),
}

impl From<YouTubeError> for tonic::Status {
    fn from(e: YouTubeError) -> Self {
        match e {
            YouTubeError::QuotaExceeded => tonic::Status::unavailable(
                "YouTube service temporarily unavailable, please try again later",
            ),
            YouTubeError::NotFound => tonic::Status::not_found("YouTube channel not found"),
            YouTubeError::Network(err) => {
                error!("YouTube API network error: {}", err);
                tonic::Status::unavailable(
                    "YouTube service temporarily unavailable, please try again later",
                )
            }
            YouTubeError::Unexpected(msg) => {
                error!("YouTube API unexpected error: {}", msg);
                tonic::Status::internal("Internal error communicating with YouTube")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Private serde types for YouTube API responses
// ---------------------------------------------------------------------------

#[derive(Deserialize)]
struct ApiListResponse<T> {
    items: Option<Vec<T>>,
}

#[derive(Deserialize)]
struct ApiErrorResponse {
    error: ApiErrorDetails,
}

#[derive(Deserialize)]
struct ApiErrorDetails {
    errors: Option<Vec<ApiErrorItem>>,
}

#[derive(Deserialize)]
struct ApiErrorItem {
    reason: Option<String>,
}

// search.list items
#[derive(Deserialize)]
struct SearchItem {
    id: SearchItemId,
}

#[derive(Deserialize)]
struct SearchItemId {
    #[serde(rename = "channelId")]
    channel_id: String,
}

// channels.list items
#[derive(Deserialize)]
struct ChannelItem {
    id: String,
    snippet: Option<ChannelSnippet>,
    statistics: Option<ChannelStatistics>,
    #[serde(rename = "contentDetails")]
    content_details: Option<ChannelContentDetails>,
}

#[derive(Deserialize)]
struct ChannelSnippet {
    title: String,
    description: String,
    thumbnails: Option<Thumbnails>,
}

#[derive(Deserialize)]
struct ChannelStatistics {
    #[serde(rename = "subscriberCount")]
    subscriber_count: Option<String>,
}

#[derive(Deserialize)]
struct ChannelContentDetails {
    #[serde(rename = "relatedPlaylists")]
    related_playlists: RelatedPlaylists,
}

#[derive(Deserialize)]
struct RelatedPlaylists {
    uploads: String,
}

// playlistItems.list items
#[derive(Deserialize)]
struct PlaylistItemEntry {
    snippet: Option<PlaylistItemSnippet>,
    #[serde(rename = "contentDetails")]
    content_details: Option<PlaylistItemContentDetails>,
}

#[derive(Deserialize)]
struct PlaylistItemSnippet {
    title: String,
    description: String,
    thumbnails: Option<Thumbnails>,
    #[serde(rename = "publishedAt")]
    published_at: Option<String>,
}

#[derive(Deserialize)]
struct PlaylistItemContentDetails {
    #[serde(rename = "videoId")]
    video_id: String,
}

// Thumbnails (shared)
#[derive(Deserialize)]
struct Thumbnails {
    maxres: Option<ThumbnailEntry>,
    high: Option<ThumbnailEntry>,
    medium: Option<ThumbnailEntry>,
    default: Option<ThumbnailEntry>,
}

#[derive(Deserialize)]
struct ThumbnailEntry {
    url: String,
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn best_thumbnail(thumbnails: Option<&Thumbnails>) -> String {
    thumbnails
        .and_then(|t| {
            t.maxres
                .as_ref()
                .or(t.high.as_ref())
                .or(t.medium.as_ref())
                .or(t.default.as_ref())
        })
        .map(|t| t.url.clone())
        .unwrap_or_default()
}

// ---------------------------------------------------------------------------
// Client implementation
// ---------------------------------------------------------------------------

impl YouTubeClient {
    pub fn new(api_key: String) -> Self {
        Self {
            http: reqwest::Client::new(),
            api_key,
        }
    }

    async fn handle_response(&self, response: reqwest::Response) -> Result<reqwest::Response, YouTubeError> {
        let status = response.status();
        if status.is_success() {
            return Ok(response);
        }
        if status == reqwest::StatusCode::FORBIDDEN {
            // Check if it's a quota exceeded error
            if let Ok(err_body) = response.json::<ApiErrorResponse>().await {
                if let Some(errors) = err_body.error.errors {
                    if errors.iter().any(|e| e.reason.as_deref() == Some("quotaExceeded")) {
                        return Err(YouTubeError::QuotaExceeded);
                    }
                }
            }
        }
        Err(YouTubeError::Unexpected(format!("HTTP {}", status)))
    }

    /// Search for YouTube channels matching the query. Returns up to 5 results with full details.
    pub async fn search_channels(&self, query: &str) -> Result<Vec<YouTubeChannel>, YouTubeError> {
        // Step 1: search.list to get channel IDs (~100 quota units)
        let search_resp = self
            .http
            .get(format!("{}/search", BASE_URL))
            .query(&[
                ("part", "snippet"),
                ("type", "channel"),
                ("q", query),
                ("maxResults", "5"),
                ("key", &self.api_key),
            ])
            .send()
            .await
            .map_err(YouTubeError::Network)?;

        let search_resp = self.handle_response(search_resp).await?;
        let search_data: ApiListResponse<SearchItem> = search_resp
            .json()
            .await
            .map_err(|e| YouTubeError::Unexpected(format!("parse error: {}", e)))?;

        let channel_ids: Vec<String> = search_data
            .items
            .unwrap_or_default()
            .into_iter()
            .map(|item| item.id.channel_id)
            .filter(|id| !id.is_empty())
            .collect();

        if channel_ids.is_empty() {
            return Ok(vec![]);
        }

        // Step 2: channels.list to get snippet + statistics (~1 quota unit)
        let ids_param = channel_ids.join(",");
        let channels_resp = self
            .http
            .get(format!("{}/channels", BASE_URL))
            .query(&[
                ("part", "snippet,statistics"),
                ("id", ids_param.as_str()),
                ("key", &self.api_key),
            ])
            .send()
            .await
            .map_err(YouTubeError::Network)?;

        let channels_resp = self.handle_response(channels_resp).await?;
        let channels_data: ApiListResponse<ChannelItem> = channels_resp
            .json()
            .await
            .map_err(|e| YouTubeError::Unexpected(format!("parse error: {}", e)))?;

        let channels = channels_data
            .items
            .unwrap_or_default()
            .into_iter()
            .map(|item| {
                let snippet = item.snippet.unwrap_or(ChannelSnippet {
                    title: String::new(),
                    description: String::new(),
                    thumbnails: None,
                });
                let subscriber_count = item
                    .statistics
                    .and_then(|s| s.subscriber_count)
                    .and_then(|c| c.parse::<u64>().ok());
                YouTubeChannel {
                    channel_id: item.id,
                    title: snippet.title,
                    description: snippet.description,
                    image_url: best_thumbnail(snippet.thumbnails.as_ref()),
                    subscriber_count,
                }
            })
            .collect();

        Ok(channels)
    }

    /// Fetch the 10 most recent videos published within the last 30 days from a channel.
    pub async fn get_recent_videos(&self, channel_id: &str) -> Result<Vec<YouTubeVideo>, YouTubeError> {
        // Step 1: channels.list with contentDetails to get the uploads playlist ID (~1 quota unit)
        let channels_resp = self
            .http
            .get(format!("{}/channels", BASE_URL))
            .query(&[
                ("part", "contentDetails"),
                ("id", channel_id),
                ("key", &self.api_key),
            ])
            .send()
            .await
            .map_err(YouTubeError::Network)?;

        let channels_resp = self.handle_response(channels_resp).await?;
        let channels_data: ApiListResponse<ChannelItem> = channels_resp
            .json()
            .await
            .map_err(|e| YouTubeError::Unexpected(format!("parse error: {}", e)))?;

        let uploads_playlist_id = channels_data
            .items
            .and_then(|mut items| items.pop())
            .and_then(|item| item.content_details)
            .map(|cd| cd.related_playlists.uploads)
            .ok_or(YouTubeError::NotFound)?;

        // Step 2: playlistItems.list to get the most recent uploads (~1 quota unit)
        let playlist_resp = self
            .http
            .get(format!("{}/playlistItems", BASE_URL))
            .query(&[
                ("part", "snippet,contentDetails"),
                ("playlistId", uploads_playlist_id.as_str()),
                ("maxResults", "10"),
                ("key", &self.api_key),
            ])
            .send()
            .await
            .map_err(YouTubeError::Network)?;

        let playlist_resp = self.handle_response(playlist_resp).await?;
        let playlist_data: ApiListResponse<PlaylistItemEntry> = playlist_resp
            .json()
            .await
            .map_err(|e| YouTubeError::Unexpected(format!("parse error: {}", e)))?;

        let cutoff: DateTime<Utc> = Utc::now() - Duration::days(30);

        let videos = playlist_data
            .items
            .unwrap_or_default()
            .into_iter()
            .filter_map(|item| {
                let snippet = item.snippet?;
                let content_details = item.content_details?;
                let published_at = snippet.published_at.clone().unwrap_or_default();

                // Filter to only videos published within the last 30 days
                if !published_at.is_empty() {
                    if let Ok(dt) = DateTime::parse_from_rfc3339(&published_at) {
                        if dt.with_timezone(&Utc) < cutoff {
                            return None;
                        }
                    }
                }

                Some(YouTubeVideo {
                    video_id: content_details.video_id,
                    title: snippet.title,
                    description: snippet.description,
                    image_url: best_thumbnail(snippet.thumbnails.as_ref()),
                    published_at,
                })
            })
            .collect();

        Ok(videos)
    }
}
