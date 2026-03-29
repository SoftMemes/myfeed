# Bootstrap Basic Contracts Specification

> **Version**: 1.0 (March 2026)
> **Status**: Draft
> **Last Updated**: 2026-03-29

## Description

gRPC service and contracts for managing sources, subscriptions, and feed items.

Two services:

**SubscriptionService** — allows the user to add/remove/update sources (such as YouTube, Netflix) as well as managing individual subscriptions within those sources (e.g. search for a YouTube channel and add it as a subscription). This is a consistent flow for all source types, though specific types may get specific detailed inputs later for structured search.

**FeedService** — used to get feed items for the user, with one method for getting feed items based on the user's subscriptions. There may be filters but it is a read-only service.

All of this has the user authenticated implicitly via headers — no user identity fields in the contracts.

---

*This is a draft specification. Use `/refine-spec bootstrap-basic-contracts` to develop it further with structured questioning and technical details.*
