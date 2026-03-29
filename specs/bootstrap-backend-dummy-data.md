# Bootstrap Backend Dummy Data Specification

> **Version**: 2.0 (March 2026)
> **Status**: Ready for Implementation
> **Last Updated**: 2026-03-29

## Description

Implement the `SubscriptionService` and `FeedService` gRPC APIs inside `services/api` using an in-memory store backed by pre-seeded fixture data. A single implicit user is assumed throughout — no multi-user support. The repository abstraction must be shaped so the in-memory implementation can be swapped for a real Firestore implementation without structural changes to the service layer.

Cross-reference the web prototype spec for consistent terminology and fixture content.

---

## Scope

- Wire up proto codegen (`build.rs` + `tonic-build`) in `services/api`
- Implement `SubscriptionService` (7 RPCs) and `FeedService` (1 RPC)
- In-memory store with one-trait-per-aggregate pattern
- Pre-seeded fixture data (Sources, Subscriptions, FeedItems)
- Auto-generate mock FeedItems when `AddSubscription` is called
- Mock `SearchSubscribables` with hardcoded results per `platform_type`, streamed with ~150ms delay per result, filtered by query string (case-insensitive `display_name` contains)
- Auth: accept any token (or none), always treat as the single implicit user
- Pagination: real cursor logic (`page_size` + opaque cursor)
- Error handling: correct gRPC status codes + `google.rpc.ErrorInfo` details
- State is in-memory only — resets on restart; fixtures restore it

---

## Project Structure

`services/` is an existing Cargo workspace with `services/api/` partially set up. The following changes are needed:

```
services/
├── Cargo.toml                  # workspace — add api to members if not already present
└── api/
    ├── Cargo.toml              # add tonic, prost, tokio, tonic-build (build-dep)
    ├── build.rs                # NEW — tonic-build pointing at ../../contracts/
    └── src/
        ├── main.rs             # gRPC server setup + store init + service wiring
        ├── services/
        │   ├── mod.rs
        │   ├── subscription_service.rs   # tonic impl for SubscriptionService
        │   └── feed_service.rs           # tonic impl for FeedService
        └── store/
            ├── mod.rs                    # re-exports traits + in-memory impl
            ├── repository.rs             # SourceRepository, SubscriptionRepository, FeedRepository traits
            └── in_memory.rs              # InMemoryStore: impl of all three traits + seed data
```

---

## Proto Codegen (`build.rs`)

Use `tonic-build` to compile all `.proto` files from `../../contracts/com/softmemes/myfeed/v1/`:

```rust
// services/api/build.rs
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_server(true)
        .build_client(false)
        .compile_protos(
            &[
                "../../contracts/com/softmemes/myfeed/v1/common.proto",
                "../../contracts/com/softmemes/myfeed/v1/sources.proto",
                "../../contracts/com/softmemes/myfeed/v1/subscriptions.proto",
                "../../contracts/com/softmemes/myfeed/v1/feed.proto",
            ],
            &["../../contracts"],
        )?;
    Ok(())
}
```

Include generated code in service files via `tonic::include_proto!("com.softmemes.myfeed.v1")`.

---

## Repository Traits

Three traits in `store/repository.rs`. All methods are `async`. All return `Result<T, tonic::Status>` so errors propagate directly to gRPC handlers.

### `SourceRepository`
```
create_source(platform_type, display_name) → Source
delete_source(source_id) → ()              // cascades to subscriptions
list_sources(page_size, cursor) → (Vec<Source>, Option<cursor>)
```

### `SubscriptionRepository`
```
add_subscription(source_id, external_id, display_name, description, image_url) → Subscription
remove_subscription(subscription_id) → ()
list_subscriptions(source_id?, page_size, cursor) → (Vec<Subscription>, Option<cursor>)
get_subscribables(platform_type, query) → Vec<Subscribable>  // for mock catalog lookup
```

### `FeedRepository`
```
seed_feed_items(subscription: &Subscription)  // called internally on AddSubscription
get_feed(source_id?, subscription_id?, after?, before?, page_size, cursor) → (Vec<FeedItem>, Option<cursor>)
```

`InMemoryStore` in `store/in_memory.rs` implements all three traits. It holds three `Vec`s protected by `Arc<RwLock<_>>` (or `Arc<Mutex<_>>`):
- `sources: Vec<Source>`
- `subscriptions: Vec<Subscription>`
- `feed_items: Vec<FeedItem>`

---

## Fixture Seed Data

`InMemoryStore::new()` pre-populates the store with:

**Sources (2):**
- `platform_type: "youtube"`, `display_name: "YouTube"`
- `platform_type: "podcast"`, `display_name: "Podcasts"`

**Subscriptions (3):**
- YouTube source → `external_id: "UC_x5XG1OV2P6uZZ5FSM9Ttw"`, `display_name: "Google Developers"`, with description + image_url
- YouTube source → `external_id: "UCVHFbw7woebKtffS8kAoMDg"`, `display_name: "Fireship"`, with description + image_url
- Podcast source → `external_id: "podcast-syntax-fm"`, `display_name: "Syntax.fm"`, with description + image_url

**FeedItems (3 per subscription, 9 total):** Realistic-looking fake items with plausible titles, descriptions, and placeholder image URLs. Timestamps spread over the past 30 days.

---

## Mock SearchSubscribables Catalog

`InMemoryStore` holds a static catalog of `Subscribable` entries keyed by `platform_type`. On `SearchSubscribables`, the handler:

1. Looks up the catalog for the source's `platform_type`
2. Filters to entries where `display_name` contains `query` (case-insensitive); if `query` is empty, returns all
3. Streams each result individually with a `tokio::time::sleep(Duration::from_millis(150))` between each

**Catalog entries (examples):**

`"youtube"` → 8–10 entries: Google Developers, Fireship, Theo - t3.gg, Primeagen, TechLead, Traversy Media, etc.

`"podcast"` → 6–8 entries: Syntax.fm, Changelog, Software Engineering Daily, Darknet Diaries, etc.

Unknown `platform_type` → stream zero results.

---

## FeedItem Auto-Generation

When `AddSubscription` succeeds, `FeedRepository::seed_feed_items` is called with the new subscription. It generates 3 fake `FeedItem`s with:
- `id`: new UUID
- `source_id`, `subscription_id`: from the subscription
- `platform_type`: looked up from the parent Source
- `title`, `description`, `url`, `image_url`: plausible fake values including the subscription's `display_name`
- `published_at`: spaced ~3 days apart going backwards from now

---

## Auth Handling

A tonic interceptor (or inline check in each handler) extracts the `authorization` metadata header if present but does not validate it. The call always proceeds as the single implicit user. Returns `UNAUTHENTICATED` only if no header is present **and** the `REQUIRE_AUTH` environment variable is set to `1` (off by default, for future use).

---

## Pagination

Cursor is a base64-encoded index (the 0-based position of the last returned item in the sorted list). Decode on incoming requests, encode on outgoing `next_page_token`. If `page_size` is 0 or absent, default to 20. If the cursor is invalid, return `INVALID_ARGUMENT`.

---

## Error Handling

Return correct gRPC status codes with `google.rpc.ErrorInfo` details (domain `"myfeed.softmemes.com"`):

| Scenario | Code | `reason` field |
|---|---|---|
| Source not found | `NOT_FOUND` | `"SOURCE_NOT_FOUND"` |
| Subscription not found | `NOT_FOUND` | `"SUBSCRIPTION_NOT_FOUND"` |
| Subscription already exists (same source + external_id) | `ALREADY_EXISTS` | `"SUBSCRIPTION_ALREADY_EXISTS"` |
| Missing required field | `INVALID_ARGUMENT` | `"MISSING_FIELD"` |
| Invalid cursor | `INVALID_ARGUMENT` | `"INVALID_PAGE_TOKEN"` |

Use `tonic_types::StatusExt` (or `prost_types` + manual `Any` packing) to attach `ErrorInfo` to status responses.

---

## Key Cargo Dependencies

```toml
[dependencies]
tonic = { version = "0.12", features = ["transport"] }
prost = "0.13"
prost-types = "0.13"
tokio = { version = "1", features = ["full"] }
uuid = { version = "1", features = ["v4"] }
base64 = "0.22"
tonic-types = "0.12"  # for ErrorInfo / StatusExt

[build-dependencies]
tonic-build = "0.12"
```

---

## Files to Create / Modify

| File | Action |
|---|---|
| `services/Cargo.toml` | Confirm `api` in workspace members |
| `services/api/Cargo.toml` | Add all dependencies above |
| `services/api/build.rs` | Create — tonic-build proto compilation |
| `services/api/src/main.rs` | Update — wire up services + store |
| `services/api/src/services/mod.rs` | Create |
| `services/api/src/services/subscription_service.rs` | Create — SubscriptionService impl |
| `services/api/src/services/feed_service.rs` | Create — FeedService impl |
| `services/api/src/store/mod.rs` | Create |
| `services/api/src/store/repository.rs` | Create — trait definitions |
| `services/api/src/store/in_memory.rs` | Create — InMemoryStore + fixtures + mock catalog |

---

## Verification

1. `cargo build -p api` — compiles cleanly including proto codegen
2. `cargo run -p api` — server starts on configured port
3. Use grpcurl or a gRPC client to:
   - `ListSources` → returns 2 seeded sources
   - `SearchSubscribables` on youtube source with `query: "fire"` → streams "Fireship" result
   - `AddSubscription` → returns new subscription; subsequent `GetFeed` includes 3 new items
   - `DeleteSource` → cascades; `ListSubscriptions` for that source returns empty
   - `GetFeed` with `subscription_id` filter → returns only that subscription's items
   - `GetFeed` with `page_size: 2` → returns 2 items with a valid `next_page_token`
