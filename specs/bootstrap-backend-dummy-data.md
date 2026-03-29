# Bootstrap Backend Dummy Data Specification

> **Version**: 1.0 (March 2026)
> **Status**: Draft
> **Last Updated**: 2026-03-29

## Description

Implementing the APIs from the contracts in the `api` backend service, cross-referencing with the web prototype spec. This covers all functionality to discover things to subscribe to, track state, and return feed items — but backed entirely by in-memory mock state rather than a real database.

A single user is assumed implicitly (no multi-user concern at this stage). The shape of services and abstractions (e.g. repositories) should be designed so that the in-memory implementation can be swapped out for a real implementation later without structural changes.

---

*This is a draft specification. Use `/refine-spec bootstrap-backend-dummy-data` to develop it further with structured questioning and technical details.*
