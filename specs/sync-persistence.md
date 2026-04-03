# Sync Persistence Specification

> **Version**: 2.0 (April 2026)
> **Status**: Ready for Implementation
> **Last Updated**: 2026-04-03

## Description

Replace the in-memory store (`InMemoryStore`) in the API service with Firestore-backed persistence. All data — sources, subscriptions, and feed items — will be stored under per-user Firestore subcollections using a hardcoded placeholder user ID during the single-user development phase.

When a subscription is added via `AddSubscription`, the service fetches feed items from the platform (e.g. YouTube) and persists them to Firestore atomically with the subscription. If feed item storage fails, the entire operation rolls back (subscription is not created). When a subscription is removed, its associated feed items are deleted.

A new `RefreshAllSubscriptions` RPC is added to `SubscriptionService`. It iterates all subscriptions for the user, re-fetches content from each platform, and upserts feed items by `external_id` (update existing, insert new). This RPC is synchronous — the client waits for the full result. A dev-only "Refresh (Dev)" button is added to the top of the web feed page to invoke it.

`GetFeed` and all other read operations switch from in-memory to Firestore queries with no client-facing API changes.

---

## Architecture & Design

### Store Swap Strategy

The existing repository trait layer (`SourceRepository`, `SubscriptionRepository`, `FeedRepository`) remains unchanged. A new `FirestoreStore` struct implements all three traits, replacing `InMemoryStore` in `main.rs`. The `InMemoryStore` is kept for tests but is no longer used in production wiring.

### Placeholder User ID

Until real Firebase Authentication is integrated, all Firestore operations use a hardcoded constant:

```rust
// services/api/src/store/firestore.rs (or a shared constants module)
pub const PLACEHOLDER_USER_ID: &str = "dev-user-1";
```

This constant is used as the `{userId}` path segment in all Firestore collection paths.

### Sync Trigger Model

Sync happens only on explicit user actions:
1. **AddSubscription** — fetch + persist feed items as part of subscription creation
2. **RemoveSubscription** — delete associated feed items as part of subscription removal
3. **RefreshAllSubscriptions** — manual re-sync of all subscriptions (dev-only button)

There is no background polling or periodic sync in this phase.

---

## Data Model (Firestore)

All data lives under the user's document. Collection paths use the placeholder user ID.

### Collection: `users/{userId}/sources`

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Document ID (UUID) |
| `platform_type` | `string` | e.g. `"youtube"`, `"podcast"` |
| `display_name` | `string` | User-facing label |
| `created_at` | `Timestamp` | Firestore server timestamp |
| `updated_at` | `Timestamp` | Firestore server timestamp |

### Collection: `users/{userId}/subscriptions`

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Document ID (UUID) |
| `source_id` | `string` | Reference to parent source |
| `external_id` | `string` | Platform identifier (e.g. YouTube channel ID) |
| `display_name` | `string` | Channel/podcast name |
| `description` | `string` | Channel/podcast description |
| `image_url` | `string` | Avatar/thumbnail URL |
| `created_at` | `Timestamp` | Firestore server timestamp |
| `updated_at` | `Timestamp` | Firestore server timestamp |

### Collection: `users/{userId}/feed_items`

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Document ID (UUID) |
| `source_id` | `string` | Reference to parent source |
| `subscription_id` | `string` | Reference to parent subscription |
| `platform_type` | `string` | e.g. `"youtube"` |
| `external_id` | `string` | Platform content ID (e.g. YouTube video ID) — used for upsert deduplication |
| `title` | `string` | Content title |
| `description` | `string` | Content description (truncated) |
| `url` | `string` | Link to original content |
| `image_url` | `string` | Thumbnail URL |
| `published_at` | `Timestamp` | Original publication time |
| `created_at` | `Timestamp` | When first stored in myfeed |
| `updated_at` | `Timestamp` | Last upsert time |

**Deduplication**: Feed items are keried by `external_id` within a subscription. On refresh, items are upserted: if an item with the same `external_id` already exists for that subscription, it is updated in place; otherwise a new document is created.

---

## API Changes (Proto)

### New messages in `contracts/com/softmemes/myfeed/v1/subscriptions.proto`

```protobuf
// Add to SubscriptionService:
//   rpc RefreshAllSubscriptions(RefreshAllSubscriptionsRequest) returns (RefreshAllSubscriptionsResponse) {}

message RefreshAllSubscriptionsRequest {}

message RefreshAllSubscriptionsResponse {
  // Total number of feed items synced across all subscriptions.
  int32 total_items_synced = 1;
  // Per-subscription sync results.
  repeated SubscriptionSyncResult results = 2;
}

message SubscriptionSyncResult {
  string subscription_id = 1;
  string display_name = 2;
  // Number of items synced for this subscription.
  int32 items_synced = 3;
  // Empty on success; contains error message on failure.
  string error = 4;
}
```

### New RPC in `SubscriptionService`

```protobuf
service SubscriptionService {
  // ... existing RPCs ...

  // RefreshAllSubscriptions re-fetches content for every subscription
  // belonging to the authenticated user and upserts feed items.
  // Synchronous — blocks until all subscriptions are processed.
  rpc RefreshAllSubscriptions(RefreshAllSubscriptionsRequest) returns (RefreshAllSubscriptionsResponse) {}
}
```

### FeedItem proto change

Add `external_id` field to the `FeedItem` message in `contracts/com/softmemes/myfeed/v1/feed.proto`:

```protobuf
message FeedItem {
  string id = 1;
  string source_id = 2;
  string subscription_id = 3;
  string platform_type = 4;
  string title = 5;
  string description = 6;
  string url = 7;
  string image_url = 8;
  google.protobuf.Timestamp published_at = 9;
  // Platform-specific content identifier for deduplication (e.g. YouTube video ID).
  string external_id = 10;
}
```

---

## Rust Implementation Plan

### 1. Add `firestore` crate dependency

**File**: `services/Cargo.toml` (workspace dependencies)

Add:
```toml
firestore = "0.43"  # or latest
```

**File**: `services/api/Cargo.toml`

Add:
```toml
firestore = { workspace = true }
```

### 2. Create `FirestoreStore`

**New file**: `services/api/src/store/firestore.rs`

```rust
use firestore::FirestoreDb;
use std::sync::Arc;

pub const PLACEHOLDER_USER_ID: &str = "dev-user-1";

#[derive(Clone)]
pub struct FirestoreStore {
    db: Arc<FirestoreDb>,
}

impl FirestoreStore {
    pub async fn new(project_id: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let db = FirestoreDb::new(project_id).await?;
        Ok(Self { db: Arc::new(db) })
    }

    fn user_collection(&self, subcollection: &str) -> String {
        format!("users/{}/{}",PLACEHOLDER_USER_ID, subcollection)
    }
}
```

Implement `SourceRepository`, `SubscriptionRepository`, and `FeedRepository` for `FirestoreStore`:

- **`SourceRepository`**: CRUD on `users/{userId}/sources` collection
- **`SubscriptionRepository`**: CRUD on `users/{userId}/subscriptions` collection; `add_subscription` checks for duplicate `external_id` within `source_id`; `remove_subscription` cascade-deletes feed items where `subscription_id` matches
- **`FeedRepository`**:
  - `store_feed_items`: Upserts by querying for existing docs with matching `subscription_id` + `external_id`, then updating or creating
  - `get_feed`: Queries `users/{userId}/feed_items` with optional filters on `source_id`, `subscription_id`, `published_at` range; orders by `published_at` descending; uses cursor-based pagination

### 3. Update `store/mod.rs`

**File**: `services/api/src/store/mod.rs`

Add:
```rust
pub mod firestore;
pub use firestore::FirestoreStore;
```

### 4. Update repository traits

**File**: `services/api/src/store/repository.rs`

Add a `user_id` parameter is NOT needed at the trait level for this phase — `FirestoreStore` internally uses `PLACEHOLDER_USER_ID`. The trait signatures remain unchanged.

Add a new method to `FeedRepository` for upsert support:

```rust
/// Upsert feed items, deduplicating by external_id within a subscription.
/// Items with a matching (subscription_id, external_id) are updated;
/// new items are inserted.
fn upsert_feed_items(
    &self,
    items: Vec<FeedItem>,
) -> impl Future<Output = Result<usize, tonic::Status>> + Send;
```

Also add to `FeedRepository`:

```rust
/// Delete all feed items belonging to a subscription.
fn delete_feed_items_by_subscription(
    &self,
    subscription_id: &str,
) -> impl Future<Output = Result<(), tonic::Status>> + Send;
```

And add to `SubscriptionRepository`:

```rust
/// Get a single subscription by ID.
fn get_subscription(
    &self,
    subscription_id: &str,
) -> impl Future<Output = Result<Subscription, tonic::Status>> + Send;
```

Update `InMemoryStore` to implement these new trait methods (trivial in-memory implementations for test compatibility).

### 5. Update `content.rs` — `external_id` on FeedItem

**File**: `services/api/src/content.rs`

The `youtube_video_to_feed_item` function must populate the new `external_id` field on `FeedItem` with the YouTube video ID:

```rust
FeedItem {
    // ... existing fields ...
    external_id: video.video_id.clone(),
}
```

### 6. Update `subscription_service.rs`

**File**: `services/api/src/services/subscription_service.rs`

**Change `add_subscription`**: Make feed item storage failure fail the whole RPC. Replace the current fire-and-forget pattern:

```rust
// BEFORE (current):
let items = self.content.fetch_feed_items(...).await.unwrap_or_default();
if !items.is_empty() {
    let _ = self.store.store_feed_items(items).await;
}

// AFTER:
let items = self.content.fetch_feed_items(...).await.map_err(|e| {
    // Rollback: remove the subscription we just created
    // (best-effort — log if this also fails)
    tonic::Status::internal(format!("failed to fetch feed items: {}", e.message()))
})?;
if !items.is_empty() {
    self.store.store_feed_items(items).await.map_err(|e| {
        tonic::Status::internal(format!("failed to store feed items: {}", e.message()))
    })?;
}
```

On failure, remove the subscription that was just created (rollback).

**Change `remove_subscription`**: Before removing the subscription, delete its feed items:

```rust
self.store.delete_feed_items_by_subscription(&req.subscription_id).await?;
self.store.remove_subscription(&req.subscription_id).await?;
```

**Add `refresh_all_subscriptions`**: New RPC handler:

```rust
async fn refresh_all_subscriptions(
    &self,
    request: Request<RefreshAllSubscriptionsRequest>,
) -> Result<Response<RefreshAllSubscriptionsResponse>, Status> {
    check_auth(request.metadata())?;

    // 1. List all subscriptions (paginate through all pages)
    let mut all_subs = Vec::new();
    let mut offset = 0;
    loop {
        let (subs, _next) = self.store.list_subscriptions(None, 100, offset).await?;
        if subs.is_empty() { break; }
        offset += subs.len();
        all_subs.extend(subs);
    }

    // 2. For each subscription, fetch + upsert
    let mut total_items_synced: i32 = 0;
    let mut results = Vec::new();
    for sub in &all_subs {
        let source = match self.store.get_source(&sub.source_id).await {
            Ok(s) => s,
            Err(e) => {
                results.push(SubscriptionSyncResult {
                    subscription_id: sub.id.clone(),
                    display_name: sub.display_name.clone(),
                    items_synced: 0,
                    error: e.message().to_string(),
                });
                continue;
            }
        };
        match self.content.fetch_feed_items(
            &sub.id, &sub.source_id, &source.platform_type, &sub.external_id,
        ).await {
            Ok(items) => {
                let count = self.store.upsert_feed_items(items).await.unwrap_or(0) as i32;
                total_items_synced += count;
                results.push(SubscriptionSyncResult {
                    subscription_id: sub.id.clone(),
                    display_name: sub.display_name.clone(),
                    items_synced: count,
                    error: String::new(),
                });
            }
            Err(e) => {
                results.push(SubscriptionSyncResult {
                    subscription_id: sub.id.clone(),
                    display_name: sub.display_name.clone(),
                    items_synced: 0,
                    error: e.message().to_string(),
                });
            }
        }
    }

    Ok(Response::new(RefreshAllSubscriptionsResponse {
        total_items_synced,
        results,
    }))
}
```

### 7. Update `main.rs`

**File**: `services/api/src/main.rs`

Replace `InMemoryStore::new()` with `FirestoreStore::new(project_id).await?`:

```rust
let project_id = std::env::var("GCP_PROJECT_ID")
    .unwrap_or_else(|_| "myfeed-dev".to_string());
let store = FirestoreStore::new(&project_id).await?;
```

Update imports accordingly.

### 8. Regenerate proto code

After modifying the `.proto` files, run the buf/tonic code generation to update the generated Rust types (via `build.rs`) and TypeScript types (via buf).

---

## UI Changes

### Web: Add "Refresh (Dev)" button

**File**: `web/src/app/page.tsx`

Add a "Refresh (Dev)" button at the top of the feed page, above the feed grid. The button is visually marked as temporary/dev-only.

```tsx
// Inside FeedPage component, add a refresh mutation:
const refreshMutation = trpc.subscriptions.refreshAll.useMutation({
  onSuccess: () => {
    refetch(); // Re-fetch the feed after refresh completes
  },
});

// Render above the grid:
<div className="flex items-center justify-between mb-4">
  <h1 className="text-lg font-semibold">Your Feed</h1>
  <Button
    variant="outline"
    size="sm"
    onClick={() => refreshMutation.mutate()}
    disabled={refreshMutation.isPending}
    className="border-dashed border-orange-400 text-orange-600"
  >
    {refreshMutation.isPending ? "Refreshing..." : "Refresh (Dev)"}
  </Button>
</div>
```

The dashed orange border visually distinguishes this as a dev-only control.

### Web: Add tRPC router for refresh

**File**: `web/src/server/routers/subscriptions.ts`

Add a new mutation:

```typescript
refreshAll: publicProcedure
  .mutation(async () => {
    const response = await subscriptionClient.refreshAllSubscriptions({});
    return {
      totalItemsSynced: response.totalItemsSynced,
      results: response.results.map((r) => ({
        subscriptionId: r.subscriptionId,
        displayName: r.displayName,
        itemsSynced: r.itemsSynced,
        error: r.error,
      })),
    };
  }),
```

---

## Error Handling

| Scenario | Behavior |
|---|---|
| **AddSubscription: feed fetch fails** | RPC fails with `INTERNAL`. The subscription that was just created is rolled back (deleted). Client sees an error. |
| **AddSubscription: feed store fails** | Same as above — rollback subscription, fail RPC. |
| **RemoveSubscription: feed item delete fails** | RPC fails. Subscription is not removed. Client retries. |
| **RefreshAllSubscriptions: one subscription fails** | That subscription's result has a non-empty `error` field. Other subscriptions continue processing. The RPC itself succeeds with partial results. |
| **RefreshAllSubscriptions: Firestore unavailable** | If `list_subscriptions` fails, RPC returns an error. If individual upserts fail, treated as per-subscription errors (see above). |
| **Dedup conflict** | Upsert by `external_id` — no conflict, last-write-wins semantics. |
| **Firestore connection failure on startup** | `FirestoreStore::new()` returns an error; service fails to start. |

---

## Key Files to Modify

### Proto contracts
- `contracts/com/softmemes/myfeed/v1/subscriptions.proto` — add `RefreshAllSubscriptions` RPC + request/response messages + `SubscriptionSyncResult`
- `contracts/com/softmemes/myfeed/v1/feed.proto` — add `external_id` field (field number 10) to `FeedItem`

### Rust backend
- `services/Cargo.toml` — add `firestore` workspace dependency
- `services/api/Cargo.toml` — add `firestore` dependency
- **NEW** `services/api/src/store/firestore.rs` — `FirestoreStore` implementing all three repository traits
- `services/api/src/store/mod.rs` — export `FirestoreStore`
- `services/api/src/store/repository.rs` — add `upsert_feed_items`, `delete_feed_items_by_subscription`, `get_subscription` trait methods
- `services/api/src/store/in_memory.rs` — implement new trait methods for test compatibility
- `services/api/src/content.rs` — populate `external_id` on `FeedItem` in `youtube_video_to_feed_item`
- `services/api/src/services/subscription_service.rs` — add `refresh_all_subscriptions` handler; update `add_subscription` to fail on feed errors (with rollback); update `remove_subscription` to cascade-delete feed items
- `services/api/src/main.rs` — replace `InMemoryStore` with `FirestoreStore`; read `GCP_PROJECT_ID` env var

### Web frontend
- `web/src/app/page.tsx` — add "Refresh (Dev)" button above feed grid
- `web/src/server/routers/subscriptions.ts` — add `refreshAll` mutation calling `refreshAllSubscriptions` RPC
- `web/src/server/grpc.ts` — no changes needed (generated client already picks up new RPCs after codegen)
- `web/src/lib/domain.ts` — add `external_id` to `FeedItem` interface (optional, for completeness)

### Code generation
- Run `buf generate` (or equivalent Makefile target) after proto changes to regenerate TypeScript and Rust types
