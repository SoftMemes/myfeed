# Bootstrap Connect Web App to Backend Specification

> **Version**: 1.0 (March 2026)
> **Status**: Draft
> **Last Updated**: 2026-03-29

## Description

The web app currently has a prototype implementation with local state and dummy data. The backend service now has working gRPC APIs (SubscriptionService and FeedService). This spec covers connecting the two: all data in the web app must come from the real backend APIs via gRPC, with no dummy or test data remaining in the web project when done.

Architecture:
- Next.js backend methods (server-side, e.g. API routes or server components) call the Rust gRPC backend via the generated contracts
- tRPC is used for the Next.js client-to-server layer (browser → Next.js backend → gRPC service)
- Auth is out of scope for now — no auth headers need to be sent
- The backend service URL must be configurable via environment variables in the Next.js app, defaulting to `localhost:50051`

Scope includes: listing feed items, listing subscriptions, listing sources, and any other data currently served by local dummy state in the web app.

---

*This is a draft specification. Use `/refine-spec bootstrap-connect-web-app-to-backend` to develop it further with structured questioning and technical details.*
