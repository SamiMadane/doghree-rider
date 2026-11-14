# Progress

## Batch status

| Batch | Branch | Scope | Status | Merged |
|---|---|---|---|---|
| D-00 | docs/d-00-setup | CLAUDE.md, docs skeleton, audit | done | |
| D-01 | fix/d-01-startup | Audit rows 1, 2, 3, 4, 5, 7, 59 | done | 2026-11-14 |
| D-02 | fix/d-02-silent-network | Audit rows 8, 9, 10, 11, 12, 13, 50, 51 | planned | |
| D-03 | fix/d-03-auth | Audit rows 14, 15, 16, 17, 18 | planned | |
| D-04 | fix/d-04-order-actions | Audit rows 19, 20, 21, 22, 23, 24, 25, 28, 29 | planned | |
| D-05 | fix/d-05-order-lists-parsing | Audit rows 26, 27, 30, 52, 53 | planned | |
| D-06 | fix/d-06-location-ringing | Audit rows 36, 37, 38, 39 | planned | |
| D-07 | fix/d-07-notifications | Audit rows 6, 31, 32, 33, 34, 35, 54 | planned | |
| D-08 | fix/d-08-wallet | Audit rows 41, 42, 43, 44 | planned | |
| D-09 | fix/d-09-uploads-profile | Audit rows 45, 46, 47, 48, 49 | planned | |
| D-10 | fix/d-10-cleanup | Audit rows 40, 55, 56, 57, 58, 60 | planned | |

## Batch log

<!-- One section per batch: date, what changed, tests (new / total / failing on old code), analyze count, device steps and result. -->

### D-00 (2026-11-14)
- Created CLAUDE.md, docs/progress.md, docs/backend-changes.md, docs/code-traps.md, docs/api-contract.md and docs/audit-d00.md (60 findings, batches D-01 to D-10).
- Added open backend questions B-01 to B-04.
- Docs only, no app code changed.
- Analyze: 0 issues (`flutter analyze --no-pub` at dcaf6d5).
- Tests: none run. The only test is the stale default counter test, which cannot pass (audit row 59, D-01).

### D-01 (2026-11-14)
- Row 1: removed the unused `availableCameras()` probe, the `cameras` global and the camera import from `main.dart`.
- Row 2: `initSharedData` fills every missing default in one call.
- Row 3: the profile fetch returns `ProfileResult` with a `SessionStatus`.
  - 401 → expired: clear the session, stop location, set the logout reason, go to sign-in. Each step is in try/catch, and navigation always happens.
  - Offline (1), 0, 403, 5xx or a parse error → the compact NoInternetScreen with Retry. The session is kept.
- Row 4: config is loaded with `handleError: false`, so a failure gives one message (the NoInternetScreen).
- Row 5: the raw offline SnackBar is gone. When the connection comes back, the reconnect listener silently retries a failed load.
- Row 7: the duplicate `getProfile()` in default routing is gone.
- Added `SplashLoadGuard` (lib/features/splash/domain/models/). Only one splash load runs at a time, and the splash navigates at most once.
- Row 59: the stale counter test is replaced by a unit test base with hand-written fakes and no new dev dependency.
- Tests: 11 total, 11 passed, 0 failed (new tests = full suite).
  - Fail on the old code by behaviour: T1 (fresh-install defaults), T3 (config `handleError`).
  - Fail on the old code at compile time only: T4–T8 (the old code has no `ProfileResult`/`SessionStatus`).
  - Guards: T2, T9, T10, T11.
- Analyze: 0 issues.
- Device: the user reports all D-01 steps passed (start-up with internet, airplane mode then Retry, logged in with bad network, fresh install). The smoke pass also passed: accept, picked up, delivered with photo, delivery shown in earnings.

### Notes (found during D-01, not fixed)
- The `camera` dependency is now unused (pubspec unchanged). Remove it in D-10.
- Translation keys `connected` and `error_occurred` are missing from en.json and ar.json. NoInternetScreen uses `error_occurred`.
- NoInternetScreen says "No connection" for 5xx/unknown failures too. A separate server-error text could follow.
- No offline indicator exists after splash. The splash connectivity listener was the only subscriber, and it is cancelled in dispose.
- `ProfileModel.fromJson` throws when `identity_image_full_url` is missing (see code-traps.md).
- Backend docs (session): suspended and not-approved riders get 401 auth-001. A new login on another device invalidates the old token. So only 401 ends the session at splash, and no backend question is needed (no B-05).

## Open backend questions

<!-- The only place new backend questions are recorded. Move a row to docs/backend-changes.md once the owner agrees. -->

| ID | Endpoint | Question / needed change | Why | Raised in | Status |
|---|---|---|---|---|---|
| B-01 | /api/v1/delivery-man/* (current-orders, latest-orders, all-orders, order, order-details, profile, remove-account, earning-report, message/*) | Can these accept the Bearer header only, so the app stops sending `?token=` in URLs and `token` in bodies? | Tokens in URLs end up in server, proxy and CDN logs (audit row 9) | D-00 | answered (backend docs Doghri-App-Screens, rider R1-R7, 2026-10-14): Bearer is the primary auth; the token query or body field is only a fallback. The app can drop `?token=` in D-02 |
| B-02 | /api/v1/delivery-man/update-order-status | When `dm_picture_upload_status` is on, is a delivery photo mandatory? Does the server reject `delivered` without `order_proof`? | The app shows the photo section but never requires it (audit row 49) | D-00 | answered (same docs): `order_proof` is optional on the server (array, max 5, stored only with `delivered`). Requiring it in the app is an owner decision before D-09 |
| B-03 | /api/v1/delivery-man/wallet/withdrawals | Does the response include a total count for paging past `limit=20`? | Older withdrawals are never shown (audit row 42) | D-00 | answered (same docs): returns `total_size`; `limit` 1-50; `offset` is a page number starting at 1 |
| B-04 | /deliveryman-earning-report-invoice/{id} | What Content-Type and charset does the PDF response use? | The app saves decoded text as bytes, so a utf-8 charset would corrupt the file (audit row 41) | D-00 | open |
