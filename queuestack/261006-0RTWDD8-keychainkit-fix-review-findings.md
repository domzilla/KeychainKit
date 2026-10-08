---
id: '261006-0RTWDD8'
title: 'KeychainKit: fix review findings'
author: Dominic Rodemer
created_at: '2026-10-06T07:03:56.822381Z'
status: open
labels:
- master
---

## Overview

Fix the correctness bugs found in the automated review of `Keychain.swift`: a crash in numeric reads, silently dropped writes when accessibility changes, and two macOS-only query bugs in `wipeKeychain()` and `allKeys()`. Once every sub-item is done, reads never trap, `set()` always persists, and macOS behaves like iOS for wiping and listing keys.

## Sub-items

Proposed sequence, top to bottom. Check off each sub-item when it is closed.

- [x] 261006-0R84TXV — Numeric object(of:) crashes on empty array data (blocked by: none)
- [x] 261006-0R848MZ — set() with different accessibility than existing item fails (blocked by: none)
- [x] 261006-0R84ZBF — macOS wipeKeychain() deletes only first match per class (blocked by: none)
- [ ] 261006-0R8403F — macOS allKeys() returns empty set (blocked by: none)
