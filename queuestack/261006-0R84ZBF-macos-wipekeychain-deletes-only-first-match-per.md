---
id: '261006-0R84ZBF'
title: macOS wipeKeychain() deletes only first match per class
author: Dominic Rodemer
created_at: '2026-10-06T06:53:56.013712Z'
status: open
labels:
- bug
---

> **Note:** Agent-generated from an automated doc/code review. This may be a false positive — analyze and confirm against the code before fixing.

`deleteKeychainSecClass` (Keychain.swift:690-698) queries only `kSecClass`, with no `kSecMatchLimitAll`. On the file-based macOS keychain `SecItemDelete` removes only the first match. `removeAllKeys()` already handles this (Keychain.swift:649-652).
Impact: on macOS `wipeKeychain()` leaves most items behind.
Fix: add `secMatchLimit: kSecMatchLimitAll` under `#if os(macOS)`, as `removeAllKeys()` does.
