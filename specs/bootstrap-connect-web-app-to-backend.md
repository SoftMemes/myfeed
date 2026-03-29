# Bootstrap Connect Web App to Backend Specification

> **Version**: 2.0 (March 2026)
> **Status**: Implemented
> **Last Updated**: 2026-03-29

## Description

Replace all dummy/localStorage data in the Next.js web app with live data from the Rust gRPC backend. When complete, no mock data, seed logic, or localStorage state remains in the web project. All data flows through tRPC routers that call the backend via `nice-grpc`.

---

## Architecture

```
Browser
  └─ tRPC React Query hooks (@trpc/react-query)
       └─ /api/trpc/[trpc] route handler
            └─ tRPC routers (server-side)
                 └─ nice-grpc client
                      └─ Rust gRPC API  :50051
```

For streaming search (`SearchSubscribables`): tRPC subscription (SSE) → nice-grpc async iterable → server-streaming RPC.

**All pages are Client Components.** No RSC data loading — components mount and fetch via tRPC React Query hooks. Initial renders show loading skeletons.

---

## Environment Configuration

**`web/.env.local`** (gitignored; document in `.env.example`):
```
GRPC_API_URL=localhost:50051
```

Accessed in the tRPC routers as `process.env.GRPC_API_URL`. No `NEXT_PUBLIC_` prefix — this is server-side only.

---

## Proto Codegen

Two plugins in `contracts/buf.gen.yaml`:

1. **`@bufbuild/protoc-gen-es`** (already present) → `../web/generated/proto/` — TypeScript message classes
2. **`ts-proto` with nice-grpc output** (new) → `../web/generated/proto/grpc/` — service client definitions for nice-grpc

```yaml
# Add to contracts/buf.gen.yaml plugins:
- local: protoc-gen-ts_proto
  out: ../web/generated/proto/grpc
  opt:
    - outputServices=nice-grpc-client
    - esModuleInterop=true
    - env=node
    - useOptionals=messages
```

`ts-proto` generates service descriptors + typed client interfaces compatible with nice-grpc. The `@bufbuild/protoc-gen-es` message types are used directly in the tRPC routers.

---

## UI Domain Types

`src/lib/domain.ts` is **replaced** with clean UI-friendly types. Proto types are internal to `src/server/`; the UI never sees them directly.

```typescript
// src/lib/domain.ts (new)

export interface Source {
  id: string;
  platformType: string;    // e.g. "youtube", "podcast"
  displayName: string;
  createdAt: string;       // ISO 8601
}

export interface Subscription {
  id: string;
  sourceId: string;
  externalId: string;
  displayName: string;
  description: string;
  imageUrl: string;
  createdAt: string;
}

export interface Subscribable {
  externalId: string;
  displayName: string;
  description: string;
  imageUrl: string;
}

export interface FeedItem {
  id: string;
  sourceId: string;
  subscriptionId: string;
  platformType: string;
  title: string;
  description: string;
  url: string;
  imageUrl: string;
  publishedAt: string;     // ISO 8601
}
```

Proto `Timestamp` → ISO 8601 string conversion happens in the tRPC routers.

---

## New Dependencies

```json
// web/package.json additions
"dependencies": {
  "@trpc/server": "^11",
  "@trpc/client": "^11",
  "@trpc/react-query": "^11",
  "@tanstack/react-query": "^5",
  "nice-grpc": "^2",
  "@bufbuild/protobuf": "^2",
  "zod": "^3",
  "superjson": "^2"
},
"devDependencies": {
  "ts-proto": "^2"
}
```

---

## Server-Side Structure

```
web/src/server/
├── grpc.ts              # nice-grpc channel + typed clients
├── trpc.ts              # tRPC context and base procedures
└── routers/
    ├── _app.ts          # root router — merges all sub-routers
    ├── feed.ts          # getFeed query
    ├── subscriptions.ts # listSubscriptions, addSubscription, removeSubscription
    └── sources.ts       # listSources, createSource, deleteSource, searchSubscribables
```

### `src/server/grpc.ts`
Creates a single `createChannel` + service client per service, reused across requests:
```typescript
const channel = createChannel(process.env.GRPC_API_URL ?? 'localhost:50051');
export const subscriptionClient = createClient(SubscriptionServiceClient, channel);
export const feedClient = createClient(FeedServiceClient, channel);
```

### `src/server/trpc.ts`
Initialises tRPC v11 with `superjson` transformer and Zod validation. No auth context for now.

### tRPC Routers

**`feed.ts`**
- `getFeed` query — calls `feedClient.getFeed(filters)` with optional `sourceId`, `subscriptionId`, `after`, `before`, `pageSize`, `pageToken` inputs. Returns `{ items: FeedItem[], nextPageToken: string }`.

**`subscriptions.ts`**
- `list` query — `subscriptionClient.listSubscriptions({ sourceId?, page })` → `{ subscriptions: Subscription[], nextPageToken: string }`
- `add` mutation — `subscriptionClient.addSubscription({ sourceId, externalId, displayName, description, imageUrl })` → `Subscription`
- `remove` mutation — `subscriptionClient.removeSubscription({ subscriptionId })` → `void`

**`sources.ts`**
- `list` query — `subscriptionClient.listSources({ page })` → `{ sources: Source[], nextPageToken: string }`
- `create` mutation — `subscriptionClient.createSource({ platformType, displayName })` → `Source`
- `delete` mutation — `subscriptionClient.deleteSource({ sourceId })` → `void`
- `searchSubscribables` subscription — async iterable from `subscriptionClient.searchSubscribables({ sourceId, query })`, yields `Subscribable` items one at a time via tRPC observable/SSE

---

## tRPC Client Setup

```
web/src/trpc/
├── client.ts        # createTRPCReact<AppRouter>()
└── provider.tsx     # TRPCReactProvider — wraps QueryClient + tRPC httpLink
```

`/api/trpc/[trpc]/route.ts` — Next.js App Router handler for tRPC, using `fetchRequestHandler`.

For `searchSubscribables` subscription: configure tRPC with `httpSubscriptionLink` (SSE) in the client provider.

---

## Component & Page Changes

### Files to **delete**
| File | Reason |
|---|---|
| `src/lib/mock-data.ts` | Replaced by gRPC search |
| `src/lib/seed.ts` | No more seeding |
| `src/lib/storage.ts` | No more localStorage |
| `src/components/seed-provider.tsx` | No more seeding |

### Files to **modify**

**`src/app/layout.tsx`**
- Remove `<SeedProvider>`
- Add `<TRPCReactProvider>` (wraps children with QueryClient + tRPC client)

**`src/app/page.tsx`** (Feed)
- Replace localStorage reads with `trpc.feed.getFeed.useQuery(filters)`
- Show loading skeleton while fetching
- Show inline error + retry on failure
- Pagination: pass `pageToken` from previous response for "load more"

**`src/app/subscriptions/page.tsx`**
- Replace localStorage with `trpc.subscriptions.list.useQuery()`
- Remove mutation replaces localStorage write with `trpc.subscriptions.remove.useMutation()`
- On successful remove: invalidate `subscriptions.list` and `feed.getFeed` queries

**`src/app/sources/page.tsx`**
- Replace localStorage with `trpc.sources.list.useQuery()`
- **Remove enable/disable toggle** — show Delete button only
- Delete calls `trpc.sources.delete.useMutation()`, invalidates `sources.list`, `subscriptions.list`, `feed.getFeed`
- Remove "Reset Data" button (was re-seeding localStorage)

**`src/components/add-subscription-dialog.tsx`**
- Replace mock channel search with `trpc.sources.searchSubscribables.useSubscription({ sourceId, query })`
- Results stream in via SSE as the user types — show them incrementally
- Submit calls `trpc.subscriptions.add.useMutation()`
- On success: invalidate `subscriptions.list` and `feed.getFeed`
- Requires a `sourceId` to be selected before searching — add a source selector dropdown (populated from `trpc.sources.list.useQuery()`)

**`src/lib/domain.ts`** — replaced (see UI Domain Types above)

---

## Error Handling

Each page/component catches tRPC errors and shows an inline error state:
```
"Could not load [feed / subscriptions / sources]. [Retry]"
```
No global error boundary. Mutations show a toast or inline error message on failure.

---

## Files to Create

| File | Purpose |
|---|---|
| `web/.env.local` | `GRPC_API_URL=localhost:50051` |
| `web/.env.example` | Documented env vars |
| `web/src/server/grpc.ts` | nice-grpc channel + service clients |
| `web/src/server/trpc.ts` | tRPC init |
| `web/src/server/routers/_app.ts` | Root router |
| `web/src/server/routers/feed.ts` | Feed queries |
| `web/src/server/routers/subscriptions.ts` | Subscription queries + mutations |
| `web/src/server/routers/sources.ts` | Source queries + mutations + search subscription |
| `web/src/app/api/trpc/[trpc]/route.ts` | Next.js tRPC handler |
| `web/src/trpc/client.ts` | `createTRPCReact` |
| `web/src/trpc/provider.tsx` | `TRPCReactProvider` |

Also: update `contracts/buf.gen.yaml` to add ts-proto plugin and re-run `buf generate`.

---

## Verification

1. `cd contracts && buf generate` — generates both `@bufbuild/protoc-gen-es` types and `ts-proto` nice-grpc service definitions
2. `cd web && npm run dev` — Next.js starts without errors
3. Start `cargo run -p myfeed-api` in services/
4. Browser at `localhost:3000`:
   - Feed page loads and displays 9 seeded items
   - Subscriptions page shows 3 seeded subscriptions
   - Sources page shows 2 sources (YouTube, Podcasts), no toggle
   - Deleting a source removes it and clears its feed items on refresh
   - Add subscription dialog: select a source, type "fire", see "Fireship" stream in as a result, add it, see 3 new feed items
5. Stop backend → each page shows inline error + retry
6. Confirm no references to `localStorage`, `MOCK_CHANNELS`, `seedIfEmpty` remain in `web/src/`
