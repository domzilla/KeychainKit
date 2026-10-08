---
id: '261006-0R848MZ'
title: set() with different accessibility than existing item fails
author: Dominic Rodemer
created_at: '2026-10-06T06:53:56.027030Z'
status: closed
labels:
- bug
---


> **Note:** Agent-generated from an automated doc/code review. This may be a false positive — analyze and confirm against the code before fixing.

## Parent

261006-0RTWDD8

`set(_:forKey:withAccessibility:)` (Keychain.swift:574) calls `SecItemAdd` with accessibility X. `kSecAttrAccessible` is not part of the item's primary key, so an existing item with accessibility Y causes `errSecDuplicateItem`. The `update` fallback (Keychain.swift:701) then queries with `kSecAttrAccessible = X`, finds nothing, and returns false.
Impact: the write is silently dropped. The old value and old accessibility stay. The docs on `removeObject` (around line 605) describe this as expected behaviour.
Fix: in `update`, leave accessibility out of the match query and put it in the update attributes instead (or delete and re-add). Then update the docs.
