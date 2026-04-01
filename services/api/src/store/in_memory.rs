use std::sync::Arc;
use tokio::sync::RwLock;
use uuid::Uuid;

use base64::{engine::general_purpose::STANDARD as B64, Engine};

use crate::error::{already_exists, invalid_page_token, not_found};
use crate::proto::{FeedItem, Source, Subscription};
use super::repository::{FeedRepository, SourceRepository, SubscriptionRepository};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn now_secs() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

fn timestamp_secs(secs: i64) -> Option<prost_types::Timestamp> {
    Some(prost_types::Timestamp { seconds: secs, nanos: 0 })
}

fn days_ago_ts(days: i64) -> Option<prost_types::Timestamp> {
    timestamp_secs(now_secs() - days * 86400)
}

pub fn encode_cursor(offset: usize) -> String {
    B64.encode(offset.to_string())
}

pub fn decode_cursor(token: &str) -> Result<usize, tonic::Status> {
    if token.is_empty() {
        return Ok(0);
    }
    let bytes = B64.decode(token).map_err(|_| invalid_page_token())?;
    let s = String::from_utf8(bytes).map_err(|_| invalid_page_token())?;
    s.parse::<usize>().map_err(|_| invalid_page_token())
}

fn paginate<T: Clone>(items: &[T], offset: usize, page_size: usize) -> (Vec<T>, Option<String>) {
    let start = offset.min(items.len());
    let page: Vec<T> = items[start..].iter().take(page_size).cloned().collect();
    let next_offset = offset + page.len();
    let next_token = if next_offset < items.len() {
        Some(encode_cursor(next_offset))
    } else {
        None
    };
    (page, next_token)
}

// ---------------------------------------------------------------------------
// Seed helpers
// ---------------------------------------------------------------------------

fn make_source(id: &str, platform_type: &str, display_name: &str, days_ago: i64) -> Source {
    Source {
        id: id.to_string(),
        platform_type: platform_type.to_string(),
        display_name: display_name.to_string(),
        created_at: days_ago_ts(days_ago),
    }
}

fn make_subscription(
    id: &str,
    source_id: &str,
    external_id: &str,
    display_name: &str,
    description: &str,
    image_url: &str,
    days_ago: i64,
) -> Subscription {
    Subscription {
        id: id.to_string(),
        source_id: source_id.to_string(),
        external_id: external_id.to_string(),
        display_name: display_name.to_string(),
        description: description.to_string(),
        image_url: image_url.to_string(),
        created_at: days_ago_ts(days_ago),
    }
}

fn make_feed_item(
    id: &str,
    source_id: &str,
    sub_id: &str,
    platform_type: &str,
    title: &str,
    description: &str,
    url: &str,
    image_url: &str,
    days_ago: i64,
) -> FeedItem {
    FeedItem {
        id: id.to_string(),
        source_id: source_id.to_string(),
        subscription_id: sub_id.to_string(),
        platform_type: platform_type.to_string(),
        title: title.to_string(),
        description: description.to_string(),
        url: url.to_string(),
        image_url: image_url.to_string(),
        published_at: days_ago_ts(days_ago),
    }
}

// ---------------------------------------------------------------------------
// Store
// ---------------------------------------------------------------------------

struct StoreState {
    sources: Vec<Source>,
    subscriptions: Vec<Subscription>,
    feed_items: Vec<FeedItem>,
}

#[derive(Clone)]
pub struct InMemoryStore {
    state: Arc<RwLock<StoreState>>,
}

impl InMemoryStore {
    pub fn new() -> Self {
        let yt_src_id = "src-youtube-01";
        let pod_src_id = "src-podcast-01";
        let sub_gdev_id = "sub-google-dev-01";
        let sub_fire_id = "sub-fireship-01";
        let sub_syn_id = "sub-syntax-01";

        let sources = vec![
            make_source(yt_src_id, "youtube", "YouTube", 30),
            make_source(pod_src_id, "podcast", "Podcasts", 30),
        ];

        let subscriptions = vec![
            make_subscription(
                sub_gdev_id, yt_src_id, "UC_x5XG1OV2P6uZZ5FSM9Ttw",
                "Google Developers",
                "The Google Developers channel offers resources for building apps across Google platforms.",
                "https://yt3.ggpht.com/google-developers-avatar",
                25,
            ),
            make_subscription(
                sub_fire_id, yt_src_id, "UCVHFbw7woebKtffS8kAoMDg",
                "Fireship",
                "High-intensity, entertaining coding tutorials and tech news.",
                "https://yt3.ggpht.com/fireship-avatar",
                20,
            ),
            make_subscription(
                sub_syn_id, pod_src_id, "podcast-syntax-fm",
                "Syntax.fm",
                "A podcast for web developers with Wes Bos and Scott Tolinski.",
                "https://syntax.fm/logo.png",
                15,
            ),
        ];

        let feed_items = vec![
            // Google Developers
            make_feed_item("feed-gdev-1", yt_src_id, sub_gdev_id, "youtube",
                "What's new in Android Studio Narwhal",
                "Explore the latest Android Studio features including improved Gemini integration.",
                "https://youtube.com/watch?v=gdev001", "", 3),
            make_feed_item("feed-gdev-2", yt_src_id, sub_gdev_id, "youtube",
                "Building with Gemini API: a practical guide",
                "Learn how to integrate Gemini into your app with hands-on examples.",
                "https://youtube.com/watch?v=gdev002", "", 7),
            make_feed_item("feed-gdev-3", yt_src_id, sub_gdev_id, "youtube",
                "Firebase in 2025: what's changed",
                "A roundup of the biggest Firebase updates and how to migrate your app.",
                "https://youtube.com/watch?v=gdev003", "", 12),
            // Fireship
            make_feed_item("feed-fire-1", yt_src_id, sub_fire_id, "youtube",
                "Rust in 100 seconds",
                "Rust explained in 100 seconds — memory safety without a garbage collector.",
                "https://youtube.com/watch?v=fire001", "", 2),
            make_feed_item("feed-fire-2", yt_src_id, sub_fire_id, "youtube",
                "I tried every JS framework so you don't have to",
                "A rapid-fire tour of React, Vue, Svelte, Solid, and more.",
                "https://youtube.com/watch?v=fire002", "", 5),
            make_feed_item("feed-fire-3", yt_src_id, sub_fire_id, "youtube",
                "Next.js 15 is a game changer",
                "The biggest changes in Next.js 15 and what they mean for your project.",
                "https://youtube.com/watch?v=fire003", "", 10),
            // Syntax.fm
            make_feed_item("feed-syn-1", pod_src_id, sub_syn_id, "podcast",
                "Episode 742: Svelte 5 with Rich Harris",
                "Rich Harris joins Wes and Scott to talk through Svelte 5 runes and what changed.",
                "https://syntax.fm/show/742", "", 1),
            make_feed_item("feed-syn-2", pod_src_id, sub_syn_id, "podcast",
                "Episode 741: The best VS Code extensions",
                "Our favourite VS Code extensions for web development in 2025.",
                "https://syntax.fm/show/741", "", 4),
            make_feed_item("feed-syn-3", pod_src_id, sub_syn_id, "podcast",
                "Episode 740: Hot takes on CSS in 2025",
                "Container queries, cascade layers, and the future of CSS.",
                "https://syntax.fm/show/740", "", 8),
        ];

        Self {
            state: Arc::new(RwLock::new(StoreState {
                sources,
                subscriptions,
                feed_items,
            })),
        }
    }
}

// ---------------------------------------------------------------------------
// SourceRepository
// ---------------------------------------------------------------------------

impl SourceRepository for InMemoryStore {
    async fn get_source(&self, source_id: &str) -> Result<Source, tonic::Status> {
        self.state
            .read()
            .await
            .sources
            .iter()
            .find(|s| s.id == source_id)
            .cloned()
            .ok_or_else(|| not_found("SOURCE_NOT_FOUND", "source not found"))
    }

    async fn create_source(
        &self,
        platform_type: &str,
        display_name: &str,
    ) -> Result<Source, tonic::Status> {
        let source = Source {
            id: Uuid::new_v4().to_string(),
            platform_type: platform_type.to_string(),
            display_name: display_name.to_string(),
            created_at: days_ago_ts(0),
        };
        self.state.write().await.sources.push(source.clone());
        Ok(source)
    }

    async fn delete_source(&self, source_id: &str) -> Result<(), tonic::Status> {
        let mut state = self.state.write().await;
        let idx = state
            .sources
            .iter()
            .position(|s| s.id == source_id)
            .ok_or_else(|| not_found("SOURCE_NOT_FOUND", "source not found"))?;
        state.sources.remove(idx);
        // Cascade
        state.subscriptions.retain(|s| s.source_id != source_id);
        state.feed_items.retain(|f| f.source_id != source_id);
        Ok(())
    }

    async fn list_sources(
        &self,
        page_size: usize,
        offset: usize,
    ) -> Result<(Vec<Source>, Option<String>), tonic::Status> {
        let state = self.state.read().await;
        Ok(paginate(&state.sources, offset, page_size))
    }
}

// ---------------------------------------------------------------------------
// SubscriptionRepository
// ---------------------------------------------------------------------------

impl SubscriptionRepository for InMemoryStore {
    async fn add_subscription(
        &self,
        source_id: &str,
        external_id: &str,
        display_name: &str,
        description: &str,
        image_url: &str,
    ) -> Result<Subscription, tonic::Status> {
        let mut state = self.state.write().await;

        if !state.sources.iter().any(|s| s.id == source_id) {
            return Err(not_found("SOURCE_NOT_FOUND", "source not found"));
        }
        if state
            .subscriptions
            .iter()
            .any(|s| s.source_id == source_id && s.external_id == external_id)
        {
            return Err(already_exists(
                "SUBSCRIPTION_ALREADY_EXISTS",
                "subscription already exists",
            ));
        }

        let sub = Subscription {
            id: Uuid::new_v4().to_string(),
            source_id: source_id.to_string(),
            external_id: external_id.to_string(),
            display_name: display_name.to_string(),
            description: description.to_string(),
            image_url: image_url.to_string(),
            created_at: days_ago_ts(0),
        };
        state.subscriptions.push(sub.clone());
        Ok(sub)
    }

    async fn remove_subscription(&self, subscription_id: &str) -> Result<(), tonic::Status> {
        let mut state = self.state.write().await;
        let idx = state
            .subscriptions
            .iter()
            .position(|s| s.id == subscription_id)
            .ok_or_else(|| not_found("SUBSCRIPTION_NOT_FOUND", "subscription not found"))?;
        state.subscriptions.remove(idx);
        state
            .feed_items
            .retain(|f| f.subscription_id != subscription_id);
        Ok(())
    }

    async fn list_subscriptions(
        &self,
        source_id: Option<&str>,
        page_size: usize,
        offset: usize,
    ) -> Result<(Vec<Subscription>, Option<String>), tonic::Status> {
        let state = self.state.read().await;
        let filtered: Vec<Subscription> = state
            .subscriptions
            .iter()
            .filter(|s| source_id.map_or(true, |sid| s.source_id == sid))
            .cloned()
            .collect();
        Ok(paginate(&filtered, offset, page_size))
    }
}

// ---------------------------------------------------------------------------
// FeedRepository
// ---------------------------------------------------------------------------

impl FeedRepository for InMemoryStore {
    async fn store_feed_items(&self, items: Vec<FeedItem>) -> Result<(), tonic::Status> {
        self.state.write().await.feed_items.extend(items);
        Ok(())
    }

    async fn get_feed(
        &self,
        source_id: Option<&str>,
        subscription_id: Option<&str>,
        after_secs: Option<i64>,
        before_secs: Option<i64>,
        page_size: usize,
        offset: usize,
    ) -> Result<(Vec<FeedItem>, Option<String>), tonic::Status> {
        let state = self.state.read().await;
        let mut items: Vec<FeedItem> = state
            .feed_items
            .iter()
            .filter(|f| source_id.map_or(true, |sid| f.source_id == sid))
            .filter(|f| subscription_id.map_or(true, |subid| f.subscription_id == subid))
            .filter(|f| {
                after_secs.map_or(true, |ts| {
                    f.published_at.as_ref().map_or(false, |t| t.seconds >= ts)
                })
            })
            .filter(|f| {
                before_secs.map_or(true, |ts| {
                    f.published_at.as_ref().map_or(false, |t| t.seconds <= ts)
                })
            })
            .cloned()
            .collect();

        // Reverse-chronological
        items.sort_by(|a, b| {
            let a_s = a.published_at.as_ref().map_or(0, |t| t.seconds);
            let b_s = b.published_at.as_ref().map_or(0, |t| t.seconds);
            b_s.cmp(&a_s)
        });

        Ok(paginate(&items, offset, page_size))
    }
}
