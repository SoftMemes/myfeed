# myfeed

## Project Overview

**myfeed** is a cross-platform application (web + mobile) for following content you have explicitly chosen to follow. The defining principle is: **no recommendations, no algorithm** — only content the user has opted into.

Users subscribe to content sources (YouTube channels, podcasts, streaming releases, book publications, events, etc.) and see a curated feed of recent and upcoming content from those sources. Consumption happens on the original platform; myfeed surfaces previews and links out.

---

## Repository Structure

```
myfeed/
├── contracts/           # Protobuf definitions and buf configuration
├── web/                 # Next.js web client (TypeScript)
├── app/                 # Flutter mobile client (Android + iOS)
├── services/            # Rust backend services (Cargo workspace, Cloud Run)
│   ├── api/             # Public-facing gRPC API consumed by clients
│   ├── sync/            # Content source sync service
│   └── push/            # Push notification service
└── infrastructure/      # Terraform definitions (GCP)
```

---

## Architecture

### Core Principle: Clients Never Touch Firestore

All client-server communication goes through `services/api` via gRPC. Neither the web app nor the mobile app accesses Firestore directly. Firestore is an internal implementation detail of the backend services.

```
[web / app]  --gRPC-->  [services/api]  -->  [Firestore]
                              |
                         [services/sync]
                         [services/push]
```

### Authentication

Firebase Authentication is used across both clients. The same user account works on web and mobile. Auth tokens are passed to `services/api` for verification.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Web client | Next.js (TypeScript) |
| Mobile client | Flutter (Dart) — Android & iOS |
| Backend services | Rust (Cargo workspace) |
| Compute | Cloud Run (GCP) |
| Database | Firestore |
| Auth | Firebase Authentication |
| Service contracts | Protobuf / gRPC |
| Contract tooling | [buf](https://buf.build) (linting, validation, breaking change detection) |
| Infrastructure | Terraform |
| Environments | Dev + Prod (separate GCP projects) |

---

## Contracts (`contracts/`)

All inter-service and client-server communication is defined as Protobuf schemas in `contracts/`. This directory is the source of truth for all API shapes.

### Tooling
- **buf** is used for linting proto files, enforcing style, and detecting breaking changes.
- `buf.yaml` and `buf.gen.yaml` live at the root of `contracts/`.

### Code Generation

Generated code is committed or produced at build time per target language:

| Language | Generator | Used by |
|---|---|---|
| Rust | `tonic` / `prost` (via `build.rs`) | `services/` |
| TypeScript | `ts-proto` or `@bufbuild/protoc-gen-es` | `web/` |
| Dart | `protoc-gen-dart` | `app/` |

A top-level `Makefile` (or scripts in `contracts/`) provides targets to regenerate all language outputs.

---

## Backend Services (`services/`)

The services directory is a **Cargo workspace**. All Rust crates live here, sharing dependencies and build cache.

| Service | Purpose |
|---|---|
| `api` | Public gRPC server — the only entry point for clients |
| `sync` | Polls/fetches content sources and writes to Firestore |
| `push` | Sends push notifications when new content is available |

Shared Rust code (e.g. Firestore client helpers, auth verification) lives in a common workspace crate.

Each service is deployed as an independent Cloud Run service.

---

## Content Sources

myfeed is designed to integrate with multiple content source types (video platforms, podcasts, streaming services, publications, events, etc.). The specific integration strategy (official API, RSS feed, scraping) is decided per-source at implementation time.

The `sync` service implements a **pluggable source adapter pattern**: each source type is a distinct adapter, all conforming to a common interface, making it straightforward to add new integrations.

---

## Infrastructure (`infrastructure/`)

Terraform definitions for GCP resources:

- **Two environments**: `dev` and `prod`, each backed by a separate GCP project.
- Manages: Cloud Run services, Firestore, Firebase project configuration, IAM, networking.
- State stored in GCS buckets (one per environment).

---

## Key Principles

1. **No algorithm, no recommendations.** The feed shows only what the user has explicitly followed, in chronological order.
2. **Clients are thin.** Business logic lives in backend services, not in the web or mobile clients.
3. **All communication via contracts.** gRPC proto definitions in `contracts/` are the single source of truth for all APIs. Changes require updating the contract first.
4. **Firestore is a backend-only concern.** No Firestore SDK in `web/` or `app/`.
5. **Monorepo.** All components live in this repository for coherent cross-cutting changes.
