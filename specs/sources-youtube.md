# Sources: YouTube Specification

> **Version**: 2.0 (April 2026)
> **Status**: Implemented
> **Last Updated**: 2026-04-01

## Description

Replace the current dummy/mock data in the API service with real YouTube channel integration. Users can search for YouTube channels, subscribe to them, and see recent videos in their feed. All YouTube Data API v3 calls happen in the `api` service (`services/api`). Persistence and caching are out of scope — the existing in-memory store is retained, backed by repository traits so Firestore can be swapped in later.

Key points:
- Channels are the subscription unit for YouTube (not individual videos or playlists)
- Uses the YouTube Data API v3 (public data, API key auth) — no Google OAuth on behalf of the user
- Videos are fetched at subscribe time; no automatic refresh (the future `sync` service will handle that)

---

## Architecture & Design

All YouTube API calls are made from `services/api`. The new `youtube.rs` module provides an HTTP client (using `reqwest`) that wraps the YouTube Data API v3 endpoints. This client is injected into the service implementations alongside the existing store.

```
[web / app]  --gRPC-->  [services/api]  -- HTTP -->  [YouTube Data API v3]
                              |
                         [InMemoryStore]
```

The existing repository trait scaffolding (`SourceRepository`, `SubscriptionRepository`, `FeedRepository`) remains unchanged. The in-memory implementations stay in place. The YouTube client is a separate concern from storage — it fetches data from the YouTube API, and the results are stored via the repository traits.

---

## YouTube Data API Integration

A new `reqwest`-based HTTP client module (`youtube.rs`) wraps three YouTube Data API v3 endpoints:

### Endpoints Used

| Endpoint | Purpose | Quota Cost |
|---|---|---|
| `search.list?type=channel` | Find channels matching a user query | 100 units |
| `channels.list` | Get channel details (subscriber count, uploads playlist ID) | 1 unit |
| `playlistItems.list` | List recent videos from a channel's uploads playlist | 1 unit |

### Authentication

The client authenticates with an API key passed as the `key` query parameter on every request. The key is read from the `YOUTUBE_API_KEY` environment variable at startup. If the variable is missing, the service panics and refuses to start.

### Client Design

```rust
// Approximate shape — not prescriptive on exact signatures
pub struct YouTubeClient {
    http: reqwest::Client,
    api_key: String,
}

impl YouTubeClient {
    pub fn from_env() -> Self { /* reads YOUTUBE_API_KEY, panics if missing */ }
    pub async fn search_channels(&self, query: &str) -> Result<Vec<ChannelSearchResult>, YouTubeError> { ... }
    pub async fn get_channel(&self, channel_id: &str) -> Result<ChannelDetails, YouTubeError> { ... }
    pub async fn get_recent_videos(&self, channel_id: &str) -> Result<Vec<VideoItem>, YouTubeError> { ... }
}
```

---

## Manual Setup Steps

These steps must be performed once per GCP project (dev and prod):

1. **Enable YouTube Data API v3** in the Google Cloud Console under APIs & Services > Library.
2. **Create an API key** in APIs & Services > Credentials > Create Credentials > API Key.
3. **(Recommended) Restrict the API key** to YouTube Data API v3 only, under Application Restrictions / API Restrictions.
4. **Set locally**: add `YOUTUBE_API_KEY=<key>` to your `.env` file or export it in your shell.
5. **Set in Cloud Run**: configure `YOUTUBE_API_KEY` as an environment variable for the `api` service in both dev and prod deployments.

---

## Proto / Contract Changes

**None required.** The existing proto definitions already have all necessary fields:

- `FeedItem` has: `id`, `source_id`, `subscription_id`, `platform_type`, `title`, `description`, `url`, `image_url`, `published_at`
- `Subscribable` has: `external_id`, `display_name`, `description`, `image_url`, `platform_type`
- `Source` has: `platform_type` (value: `"youtube"`)

No changes to `contracts/` are needed for this spec.

---

## Repository Scaffolding

The existing repository traits in `services/api/src/store/repository.rs` remain unchanged:

- **`SourceRepository`** — manages platform source connections (e.g., a "YouTube" source)
- **`SubscriptionRepository`** — manages user subscriptions within a source; includes `get_subscribables` for search
- **`FeedRepository`** — manages feed items; includes `seed_feed_items` called at subscribe time

The `InMemoryStore` implementation (`services/api/src/store/in_memory.rs`) continues to serve as the backing store. The key change is that `get_subscribables` and `seed_feed_items` will delegate to the YouTube client for real data instead of returning mock data.

---

## API Behavior: SearchSubscribables (YouTube)

When `SearchSubscribables` is called with `platform_type = "youtube"`:

1. Call `search.list` with `type=channel`, `q=<user query>`, `part=snippet`, `maxResults=5`
2. Collect the returned channel IDs
3. Call `channels.list` with those channel IDs, `part=snippet,statistics` to get subscriber counts
4. Map results to `Subscribable` messages (see Field Mappings below)
5. Return up to 5 results

**Quota cost per search: ~101 units** (100 for search.list + 1 for channels.list)

---

## API Behavior: Subscribe (YouTube channel)

When a user subscribes to a YouTube channel:

1. Check for duplicate subscription (same `external_id` within the source) — return `ALREADY_EXISTS` if found
2. Create the subscription record via `SubscriptionRepository::add_subscription`
3. Fetch recent videos:
   a. Call `channels.list` with the channel ID, `part=contentDetails` to get the `uploads` playlist ID
   b. Call `playlistItems.list` with the uploads playlist ID, `part=snippet`, `maxResults=10`, `publishedAfter=<30 days ago>`
4. Map each video to a `FeedItem` (see Field Mappings below)
5. Store feed items via `FeedRepository::seed_feed_items`
6. Return the new `Subscription`

If the channel has no videos in the last 30 days, the subscription still succeeds — the feed items list is simply empty.

**Quota cost per subscribe: ~2 units** (1 for channels.list + 1 for playlistItems.list)

---

## API Behavior: GetFeed

No changes to the `GetFeed` flow. It reads from the `FeedRepository` as before, which now contains real YouTube video data (seeded at subscribe time) instead of mock data.

Feed items are returned in reverse chronological order, filtered by the existing parameters (`source_id`, `subscription_id`, time range, pagination).

---

## Field Mappings

### FeedItem (YouTube video)

| FeedItem field | YouTube source |
|---|---|
| `id` | Generated UUID |
| `source_id` | YouTube source ID (from the Source record) |
| `subscription_id` | Subscription ID (from the Subscription record) |
| `platform_type` | `"youtube"` |
| `title` | `snippet.title` |
| `description` | `snippet.description` (truncated to ~200 characters) |
| `url` | `https://www.youtube.com/watch?v={videoId}` |
| `image_url` | `thumbnails.maxres.url` if available, else `thumbnails.high.url` (1280x720 preferred, 480x360 fallback) |
| `published_at` | `snippet.publishedAt` (parsed to timestamp) |

### Subscribable (YouTube channel search result)

| Subscribable field | YouTube source |
|---|---|
| `external_id` | Channel ID (`UCxxxxxx`) |
| `display_name` | `snippet.title` |
| `description` | `snippet.description` prepended with subscriber count (e.g., `"1.2M subscribers - Gaming channel about..."`) |
| `image_url` | `snippet.thumbnails.high.url` |
| `platform_type` | `"youtube"` |

---

## Error Handling

| Condition | gRPC Status | Details |
|---|---|---|
| `YOUTUBE_API_KEY` env var missing | N/A — service panics at startup | Fail-fast; no graceful degradation |
| YouTube API quota exceeded (HTTP 403) | `UNAVAILABLE` | Message: "YouTube service temporarily unavailable, please try again later" |
| Channel not found / invalid channel ID | `NOT_FOUND` | Message: "YouTube channel not found" |
| Duplicate subscription (same external_id) | `ALREADY_EXISTS` | Existing behavior preserved |
| YouTube API network error | `UNAVAILABLE` | Transient error, client should retry |
| YouTube API returns unexpected response | `INTERNAL` | Log the error server-side for debugging |

---

## Quota Considerations

YouTube Data API v3 free tier provides **10,000 units per day**.

| Operation | Cost | Daily capacity at free tier |
|---|---|---|
| Channel search | ~101 units | ~99 searches/day |
| Subscribe to channel | ~2 units | ~5,000 subscribes/day |

For the initial launch (low user count, no automatic refresh), the free tier is sufficient. When the `sync` service is implemented (periodic video refresh), quota usage will increase and may require requesting a higher quota from Google.

---

## Out of Scope

- **Persistence / caching** — feed items live only in-memory; restarting the service loses all data
- **`sync` service changes** — automatic periodic refresh of videos from subscribed channels
- **Push notifications** — notifying users of new videos
- **OAuth / private subscriptions** — importing a user's existing YouTube subscriptions (explicitly excluded from this product)
- **Video playback** — myfeed links out to YouTube; no embedded player
- **Pagination of YouTube API results** — we fetch a fixed number of results (5 channels, 10 videos) without following `nextPageToken`

---

## Future Work

- **Firestore persistence** — swap `InMemoryStore` for a Firestore-backed implementation behind the same repository traits
- **`sync` service** — periodic background refresh of videos from all subscribed channels
- **Push notifications** — notify users when new videos are published
- **Quota monitoring** — track API usage and alert when approaching limits
- **Rate limiting** — per-user rate limits on search to prevent quota exhaustion
- **Additional source types** — podcasts, streaming services, etc. following the same adapter pattern

---

## Key Files to Modify

| File | Change |
|---|---|
| `services/api/src/youtube.rs` | **New file.** YouTube Data API v3 HTTP client (reqwest-based) |
| `services/api/src/main.rs` | Read `YOUTUBE_API_KEY`, create `YouTubeClient`, inject into services |
| `services/api/src/services/subscription_service.rs` | Wire `get_subscribables` and subscribe flow to use `YouTubeClient` |
| `services/api/src/services/feed_service.rs` | No changes expected (reads from repository as before) |
| `services/api/src/store/in_memory.rs` | Update `get_subscribables` and `seed_feed_items` to accept/use real YouTube data instead of generating mock data |
| `services/api/src/store/repository.rs` | No changes expected (traits are already sufficient) |
| `services/api/Cargo.toml` | Add `reqwest` dependency (with `json` feature) |
| `services/Cargo.toml` | Update workspace dependencies if needed |

---

## Testing Strategy

### Unit Tests
- **YouTube client parsing**: Test deserialization of YouTube API JSON responses (channel search results, channel details, playlist items) using recorded/fixture responses
- **Field mapping**: Test that YouTube API response structs are correctly mapped to `Subscribable` and `FeedItem` proto messages
- **Description truncation**: Test that descriptions are truncated to ~200 characters correctly
- **Thumbnail fallback**: Test that `maxres` is preferred, falling back to `high`
- **Subscriber count formatting**: Test formatting of subscriber counts (e.g., 1234567 becomes "1.2M subscribers")

### Integration Tests
- **Error mapping**: Test that YouTube API error responses (403 quota exceeded, 404 not found) are correctly mapped to gRPC status codes
- **Search-to-subscribe flow**: Test the full flow from searching for a channel to subscribing and seeing feed items
- **Duplicate subscription**: Test that subscribing to the same channel twice returns `ALREADY_EXISTS`
- **Empty channel**: Test that subscribing to a channel with no recent videos succeeds with an empty feed

### Manual Verification
- Verify end-to-end with a real API key against the YouTube Data API
- Confirm feed items appear in the web client after subscribing to a real YouTube channel
- Test with channels of varying sizes (small creator vs. large channel with frequent uploads)

---

## Implementation Notes

**Implemented**: April 2026

**Key Changes**:
- `services/api/src/youtube.rs` — New: YouTube Data API v3 HTTP client (reqwest-based)
- `services/api/src/content.rs` — New: `ContentResolver` trait + `PlatformContentResolver` impl
- `services/api/src/store/repository.rs` — Removed `get_subscribables` from `SubscriptionRepository`; renamed `seed_feed_items` → `store_feed_items(Vec<FeedItem>)`
- `services/api/src/store/in_memory.rs` — Removed catalog/mock-search logic; updated to implement `store_feed_items`
- `services/api/src/services/subscription_service.rs` — Added `C: ContentResolver` generic; wired search and subscribe through `ContentResolver`
- `services/api/src/main.rs` — Reads `YOUTUBE_API_KEY`, constructs `PlatformContentResolver`, injects into service
- `services/Cargo.toml` + `services/api/Cargo.toml` — Added `reqwest`, `serde`, `serde_json`, `chrono`

**Deviations from Spec**:
- Missing `YOUTUBE_API_KEY` logs a warning and starts with empty YouTube results (rather than panic), to support local dev without an API key. Set the env var for real YouTube integration.
