use std::future::Future;

use chrono::DateTime;
use uuid::Uuid;

use crate::proto::{FeedItem, Subscribable};
use crate::youtube::{YouTubeClient, YouTubeVideo};

// ---------------------------------------------------------------------------
// ContentResolver trait
// ---------------------------------------------------------------------------

/// Abstraction for platform-specific content fetching.
/// Keeps the repository layer as pure storage.
pub trait ContentResolver: Send + Sync + 'static {
    /// Search for subscribable items (channels, shows, etc.) on the given platform.
    fn search_subscribables(
        &self,
        platform_type: &str,
        query: &str,
    ) -> impl Future<Output = Result<Vec<Subscribable>, tonic::Status>> + Send;

    /// Fetch recent feed items for a newly added subscription.
    fn fetch_feed_items(
        &self,
        subscription_id: &str,
        source_id: &str,
        platform_type: &str,
        external_id: &str,
    ) -> impl Future<Output = Result<Vec<FeedItem>, tonic::Status>> + Send;
}

// ---------------------------------------------------------------------------
// PlatformContentResolver
// ---------------------------------------------------------------------------

#[derive(Clone)]
pub struct PlatformContentResolver {
    youtube: Option<YouTubeClient>,
}

impl PlatformContentResolver {
    pub fn new(youtube: Option<YouTubeClient>) -> Self {
        Self { youtube }
    }
}

impl ContentResolver for PlatformContentResolver {
    async fn search_subscribables(
        &self,
        platform_type: &str,
        query: &str,
    ) -> Result<Vec<Subscribable>, tonic::Status> {
        match platform_type {
            "youtube" => {
                let Some(ref yt) = self.youtube else {
                    return Ok(vec![]);
                };
                let channels = yt.search_channels(query).await.map_err(tonic::Status::from)?;
                Ok(channels
                    .into_iter()
                    .map(|ch| {
                        let subscriber_display = ch
                            .subscriber_count
                            .map(format_subscriber_count)
                            .unwrap_or_default();
                        let description = if subscriber_display.is_empty() {
                            ch.description
                        } else if ch.description.is_empty() {
                            subscriber_display
                        } else {
                            format!("{} - {}", subscriber_display, ch.description)
                        };
                        Subscribable {
                            external_id: ch.channel_id,
                            display_name: ch.title,
                            description,
                            image_url: ch.image_url,
                        }
                    })
                    .collect())
            }
            _ => Ok(vec![]),
        }
    }

    async fn fetch_feed_items(
        &self,
        subscription_id: &str,
        source_id: &str,
        platform_type: &str,
        external_id: &str,
    ) -> Result<Vec<FeedItem>, tonic::Status> {
        match platform_type {
            "youtube" => {
                let Some(ref yt) = self.youtube else {
                    return Ok(vec![]);
                };
                let videos = yt
                    .get_recent_videos(external_id)
                    .await
                    .map_err(tonic::Status::from)?;
                Ok(videos
                    .into_iter()
                    .map(|v| youtube_video_to_feed_item(v, subscription_id, source_id))
                    .collect())
            }
            _ => Ok(vec![]),
        }
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn youtube_video_to_feed_item(
    video: YouTubeVideo,
    subscription_id: &str,
    source_id: &str,
) -> FeedItem {
    let published_at = DateTime::parse_from_rfc3339(&video.published_at)
        .ok()
        .map(|dt| prost_types::Timestamp {
            seconds: dt.timestamp(),
            nanos: dt.timestamp_subsec_nanos() as i32,
        });

    FeedItem {
        id: Uuid::new_v4().to_string(),
        source_id: source_id.to_string(),
        subscription_id: subscription_id.to_string(),
        platform_type: "youtube".to_string(),
        title: video.title,
        description: truncate_description(&video.description),
        url: format!("https://www.youtube.com/watch?v={}", video.video_id),
        image_url: video.image_url,
        published_at,
    }
}

fn truncate_description(desc: &str) -> String {
    if desc.len() <= 200 {
        return desc.to_string();
    }
    let truncated = &desc[..200];
    if let Some(pos) = truncated.rfind(' ') {
        format!("{}...", &truncated[..pos])
    } else {
        format!("{}...", truncated)
    }
}

fn format_subscriber_count(count: u64) -> String {
    if count >= 1_000_000 {
        format!("{:.1}M subscribers", count as f64 / 1_000_000.0)
    } else if count >= 1_000 {
        format!("{:.1}K subscribers", count as f64 / 1_000.0)
    } else {
        format!("{} subscribers", count)
    }
}
