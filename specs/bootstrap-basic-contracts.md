# Bootstrap Basic Contracts Specification

> **Version**: 2.0 (March 2026)
> **Status**: Ready for Implementation
> **Last Updated**: 2026-03-29

## Description

gRPC contracts for managing content sources, subscriptions, and feed items. Two services: `SubscriptionService` (write-side) and `FeedService` (read-only). All RPCs require Firebase Auth token passed as gRPC metadata — no user identity fields appear anywhere in the contracts.

These contracts replace the existing placeholder protos entirely. No backward compatibility is required.

---

## Domain Model

### Source

A user's connection to a content platform. Platform type is a free-form string identifier (e.g. `"youtube"`, `"netflix"`, `"rss"`), not an enum — this allows new platforms without proto changes. A user may have multiple Sources for the same platform (e.g. two YouTube accounts).

**Fields**: `id`, `platform_type` (string), `display_name`, `created_at`

### Subscription

A specific thing within a Source that the user follows — e.g. a YouTube channel, a podcast, a keyword filter. Linked to a Source by `source_id`. `external_id` is the platform's own identifier for the thing (e.g. a YouTube channel ID).

**Fields**: `id`, `source_id`, `external_id`, `display_name`, `description`, `image_url`, `created_at`

### Subscribable

A candidate result returned by search — something the user *could* subscribe to but hasn't yet. Returned by `SearchSubscribables`.

**Fields**: `external_id`, `display_name`, `description`, `image_url`

### FeedItem

A single piece of content surfaced in the user's feed, produced by a Subscription. Links back to both the Source and the Subscription that generated it. Consumption happens on the original platform; myfeed surfaces a preview and link only.

**Fields**: `id`, `source_id`, `subscription_id`, `platform_type` (string), `title`, `description`, `url`, `image_url`, `published_at`

---

## Services

### SubscriptionService

Handles both source management and subscription management. Merges the former `SourceService` into a single service.

#### Source Management RPCs

| RPC | Request | Response | Notes |
|---|---|---|---|
| `CreateSource` | `CreateSourceRequest` | `CreateSourceResponse` | Adds a new platform connection |
| `DeleteSource` | `DeleteSourceRequest` | `DeleteSourceResponse` | Cascades: deletes all subscriptions under the source |
| `ListSources` | `ListSourcesRequest` | `ListSourcesResponse` | Returns all the user's sources; cursor-paginated |

#### Subscription Management RPCs

| RPC | Request | Response | Notes |
|---|---|---|---|
| `SearchSubscribables` | `SearchSubscribablesRequest` | `stream SearchSubscribablesResponse` | **Server-streaming** — streams individual results as they arrive from the platform API |
| `AddSubscription` | `AddSubscriptionRequest` | `AddSubscriptionResponse` | Creates a subscription within a source |
| `RemoveSubscription` | `RemoveSubscriptionRequest` | `RemoveSubscriptionResponse` | Removes a specific subscription |
| `ListSubscriptions` | `ListSubscriptionsRequest` | `ListSubscriptionsResponse` | Lists subscriptions; optionally filtered by `source_id`; cursor-paginated |

### FeedService

Read-only. Returns the user's chronological feed.

| RPC | Request | Response | Notes |
|---|---|---|---|
| `GetFeed` | `GetFeedRequest` | `GetFeedResponse` | Reverse-chronological; cursor-paginated |

**GetFeed filters** (all optional):
- `source_id` — restrict to a specific Source
- `subscription_id` — restrict to a specific Subscription
- `after` / `before` — `google.protobuf.Timestamp` date range bounds

---

## Proto File Structure

All files in `contracts/com/softmemes/myfeed/v1/`. Package `com.softmemes.myfeed.v1`.

| File | Contents |
|---|---|
| `common.proto` | `PageRequest`, `PageResponse` — remove `SourceType` enum |
| `sources.proto` | `Source`, `Subscribable` messages |
| `subscriptions.proto` | `Subscription` message, `SubscriptionService` (all RPCs) |
| `feed.proto` | `FeedItem` message, `FeedService` |
| `users.proto` | `UserProfile` — keep as-is, no service |

---

## Error Handling

Use standard gRPC status codes with `google.rpc.ErrorInfo` details (via `google.rpc.Status`).

| Scenario | gRPC Code |
|---|---|
| Source or subscription not found | `NOT_FOUND` |
| Subscription already exists | `ALREADY_EXISTS` |
| Missing or invalid auth token | `UNAUTHENTICATED` |
| Invalid request fields | `INVALID_ARGUMENT` |
| Platform API failure | `UNAVAILABLE` |

Import `google/rpc/error_details.proto` and `google/rpc/status.proto` where needed.

---

## Key Decisions

- **platform_type is a string**, not an enum — new platforms require no proto change
- **No UpdateSource** — out of scope for now
- **SearchSubscribables is server-streaming** — platform APIs may be slow; stream results as they arrive
- **Cascade delete on Source** — DeleteSource removes all associated Subscriptions
- **No user fields in contracts** — user identity always comes from gRPC metadata (Firebase Auth token)
- **Full proto replacement** — existing placeholder protos are discarded; no field number preservation required

---

## Files to Modify

- `contracts/com/softmemes/myfeed/v1/common.proto` — remove `SourceType` enum
- `contracts/com/softmemes/myfeed/v1/sources.proto` — replace with `Source` + `Subscribable` messages (no service)
- `contracts/com/softmemes/myfeed/v1/subscriptions.proto` — replace with `Subscription` + `SubscriptionService`
- `contracts/com/softmemes/myfeed/v1/feed.proto` — replace with `FeedItem` + `FeedService`
- `contracts/com/softmemes/myfeed/v1/users.proto` — no change

---

## Verification

1. `cd contracts && buf lint` — zero errors
2. `cd contracts && buf format -d` — zero diff
3. Manually review that `SearchSubscribables` is declared `server_streaming` in the proto
4. Confirm no `user_id` fields appear anywhere in request or response messages
