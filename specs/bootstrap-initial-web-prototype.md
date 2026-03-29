# Bootstrap Initial Web Prototype Specification

> **Version**: 1.1 (March 2026)
> **Status**: Ready for Implementation
> **Last Updated**: 2026-03-29

---

## Overview

A Next.js web prototype of **myfeed** that mocks all data using localStorage. The prototype demonstrates the full user flow: managing sources, adding/removing subscriptions, and viewing a chronological feed of content items.

All data is faked. There is no backend, no auth, and no real API calls. The prototype exists to validate the domain model, UX flow, and UI design before backend implementation.

**Single implicit user** — no login screen or user switching. The app always behaves as if one user is logged in.

---

## Domain Model

All naming is intentionally generic. YouTube is the reference implementation only.

### `Source`
Represents a content platform or source type. The user can enable or disable a source.

```ts
interface Source {
  id: string;            // e.g. "youtube"
  name: string;          // e.g. "YouTube"
  enabled: boolean;
  iconUrl?: string;      // Platform logo/icon
}
```

### `Subscription`
Represents the user's subscription to a specific publisher/channel on a Source.

```ts
interface Subscription {
  id: string;
  sourceId: string;      // e.g. "youtube"
  publisherName: string; // e.g. "Fireship"
  publisherAvatarUrl?: string;
  publisherDescription?: string;
  subscribedAt: string;  // ISO timestamp
}
```

### `FeedItem`
Represents a single piece of content produced by a subscription.

```ts
interface FeedItem {
  id: string;
  subscriptionId: string;
  sourceId: string;
  title: string;
  description: string;
  thumbnailUrl: string;
  url: string;           // Link to content on original platform
  publishedAt: string;   // ISO timestamp
  contentType: "video" | "podcast_episode" | "article" | "episode" | "post";
}
```

> `contentType` enables type-aware rendering and filtering in future. In this prototype all items are `"video"`.

---

## Pages & Navigation

Three pages with a top navigation bar:

| Route | Page | Purpose |
|---|---|---|
| `/` | Feed | Main chronological feed of FeedItems |
| `/subscriptions` | Subscriptions | View and manage subscriptions |
| `/sources` | Sources | View and enable/disable source types |

Navigation bar is persistent across all pages. On mobile it collapses to a hamburger or bottom nav.

---

## Feed Page (`/`)

- Displays all FeedItems from **enabled sources** in **reverse chronological order** (newest first).
- No filters, no sorting options — strictly chronological, consistent with the no-algorithm principle.
- **Load more** button at the bottom to load additional items (paginate in batches of 20).
- Clicking any card opens the item's `url` in a **new tab**.
- If all sources are disabled or there are no subscriptions, show an empty state with a prompt to add subscriptions.

### FeedItem Card Layout

```
+---------------------------+
| [Thumbnail 16:9]          |
|                           |
+---------------------------+
| Video Title Here          |
| ChannelName • 2 days ago  |
+---------------------------+
```

Cards are arranged in a responsive grid: 3 columns on desktop, 2 on tablet, 1 on mobile.

---

## Subscriptions Page (`/subscriptions`)

- Lists all current subscriptions grouped by source.
- Each subscription shows: publisher avatar, name, source badge, and a **Remove** button.
- An **Add subscription** button opens a search UI (inline or modal):
  1. User types a publisher name into a search field.
  2. Mock search returns matching results from the fixed mock channel catalogue.
  3. Already-subscribed channels are shown as disabled in results.
  4. User selects a result to subscribe.
  5. On subscribe: **5–10 fake FeedItems are immediately generated** for that subscription and added to the feed.
- Empty state prompts the user to add their first subscription.

---

## Sources Page (`/sources`)

- Lists all available source types (initially just YouTube).
- Each source shows: icon/logo, name, subscription count, and an **enable/disable toggle**.
- **Disabling a source** hides its FeedItems from the feed but preserves all subscriptions.
- Re-enabling a source restores those items in the feed.
- Source icons use actual platform logos (YouTube SVG/PNG).
- Designed for new sources to be added here in future iterations.

---

## Mock Data Strategy

### Initial seed (first load)
On first launch, localStorage is empty. The app auto-seeds with:
- **1 source**: YouTube (enabled)
- **3–4 pre-subscribed mock channels** (drawn from the mock catalogue)
- **5–10 FeedItems per subscription**, with realistic-looking fake data (titles, descriptions, thumbnails via placeholder image service, staggered `publishedAt` timestamps over the past 30 days)

### Mock channel catalogue
A fixed set of ~10 fake YouTube channels, each with:
- `id`, `name`, `avatarUrl`, `description`
- A pool of ~15 fake video titles to draw from when generating FeedItems

Channels use entirely fictional names and data (no real channel names).

### On subscribe
When the user subscribes to a channel, generate 5–10 FeedItems for it immediately. Timestamps should be recent (within the past 14 days) and interleaved with existing items in the feed.

### Data reset
A **Reset data** button is accessible from the Sources page (or a footer/settings area). Clicking it:
1. Clears all myfeed localStorage keys.
2. Re-runs the initial seed.
3. Reloads the feed.

---

## localStorage Schema

All keys are namespaced under `myfeed:`.

| Key | Contents |
|---|---|
| `myfeed:sources` | `Source[]` |
| `myfeed:subscriptions` | `Subscription[]` |
| `myfeed:feedItems` | `FeedItem[]` |

Data is serialized as JSON. No versioning or migration strategy in this prototype.

---

## UI Stack

| Concern | Choice |
|---|---|
| Framework | Next.js (TypeScript, App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Responsive target | Desktop-first, mobile-readable |
| Colour mode | Light mode only (dark mode out of scope) |
| Icons | Lucide (via shadcn/ui) + platform SVGs for source logos |

---

## Out of Scope (this prototype)

- Authentication / user accounts
- Backend services or API calls
- Real YouTube data or API integration
- Podcast, TV show, or blog source implementations (domain model supports them; UI does not need to)
- Dark mode
- Push notifications
- Feed item detail pages
- Marking items as watched/read
- Multiple users
- Any recommendation or algorithmic sorting

---

## Key Files (expected)

```
web/
├── app/
│   ├── page.tsx                  # Feed page
│   ├── subscriptions/page.tsx    # Subscriptions page
│   ├── sources/page.tsx          # Sources page
│   └── layout.tsx                # Root layout with nav
├── lib/
│   ├── domain.ts                 # TypeScript interfaces (Source, Subscription, FeedItem)
│   ├── storage.ts                # localStorage read/write helpers
│   ├── seed.ts                   # Initial seed data and reset logic
│   └── mock-data.ts              # Mock channel catalogue and FeedItem generators
└── components/
    ├── feed-item-card.tsx
    ├── subscription-row.tsx
    ├── source-row.tsx
    └── add-subscription-dialog.tsx
```
