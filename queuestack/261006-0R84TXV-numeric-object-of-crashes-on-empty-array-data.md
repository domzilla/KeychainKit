---
id: '261006-0R84TXV'
title: Numeric object(of:) crashes on empty array data
author: Dominic Rodemer
created_at: '2026-10-06T06:53:56.040537Z'
status: open
labels:
- bug
---

> **Note:** Agent-generated from an automated doc/code review. This may be a false positive — analyze and confirm against the code before fixing.

`object(of:forKey:)` for `Numeric` types (Keychain.swift:386) runs `try? JSONDecoder().decode([T].self, from: data)[0]`. `try?` does not catch an index-out-of-range trap.
Impact: if the stored data decodes to `[]` (for example, written with `set([Int](), ...)` under the same key), the app crashes.
Fix: `(try? JSONDecoder().decode([T].self, from: data))?.first`.
