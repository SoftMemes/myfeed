# Bootstrap Firestore Data Model Specification

> **Version**: 1.0 (March 2026)
> **Status**: Draft
> **Last Updated**: 2026-03-29

## Description

This spec documents the intended Firestore data model for myfeed. Its purpose is to produce a `CLAUDE.md` (or equivalent reference document) in the `services/` directory that captures agreed-upon Firestore collection and document structures.

The data model must support:
- Configuring content sources (e.g. YouTube channels, podcasts)
- User subscriptions to those sources
- Feed items derived from subscribed sources
- Multiple users

The model is designed to be consistent with the prototype and the service contracts defined in `contracts/`. See also related specs in `specs/`.

This spec does not cover code implementation — it documents the agreed structural choices (collections, document shapes, field names, relationships) so that backend services have a clear reference.

---

*This is a draft specification. Use `/refine-spec bootstrap-firestore-data-model` to develop it further with structured questioning and technical details.*
