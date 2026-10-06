---
id: '261006-0R8403F'
title: macOS allKeys() returns empty set
author: Dominic Rodemer
created_at: '2026-10-06T06:53:56.000280Z'
status: open
labels:
- bug
---

> **Note:** Agent-generated from an automated doc/code review. This may be a false positive — analyze and confirm against the code before fixing.

On macOS `setupQueryDictionary` stores `kSecAttrAccount` as a `String` (Keychain.swift:743), but `allKeys()` only reads it back as `Data` (Keychain.swift:304).
Impact: every macOS account fails the `as? Data` cast, so `allKeys()` returns an empty set even when items exist.
Fix: also accept `attr[secAttrAccount] as? String`, or fall back to the `kSecAttrGeneric` data.
