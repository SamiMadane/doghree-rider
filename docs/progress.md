# Progress

## Batch status

| Batch | Branch | Scope | Status | Merged |
|---|---|---|---|---|
| D-00 | docs/d-00-setup | CLAUDE.md, docs skeleton, audit | done | |
| D-01 | fix/d-01-startup | Audit rows 1, 2, 3, 4, 5, 7, 59 | merged, device tests pending (D-11) | 2026-11-14 |
| D-02 | fix/d-02-silent-network | Audit rows 8, 9, 10, 11, 12, 13, 50, 51 | merged, device tests pending (D-11) | 2026-11-14 |
| D-03 | fix/d-03-auth | Audit rows 14, 15, 16, 17, 18 + logout FCM (D-02 note) | merged, device tests pending (D-11) | 2026-11-19 |
| D-04 | fix/d-04-order-actions | Audit rows 19, 20, 21, 22, 23, 24, 25, 28, 29 | planned | |
| D-05 | fix/d-05-order-lists-parsing | Audit rows 26, 27, 30, 52, 53 | planned | |
| D-06 | fix/d-06-location-ringing | Audit rows 36, 37, 38, 39 | planned | |
| D-07 | fix/d-07-notifications | Audit rows 6, 31, 32, 33, 34, 35, 54 | planned | |
| D-08 | fix/d-08-wallet | Audit rows 41, 42, 43, 44 | planned | |
| D-09 | fix/d-09-uploads-profile | Audit rows 45, 46, 47, 48, 49 | planned | |
| D-10 | fix/d-10-cleanup | Audit rows 40, 55, 56, 57, 58, 60 | planned | |
| D-11 | (no code branch) | Final device pass: every pending backlog section, the smoke pass and the end-to-end order test (`docs/device-test-backlog.md`) | planned (after D-10) | |

> **Branch state.** When D-03 started, `development` was level with `origin/development` (265bcfa): D-01 and D-02 were already pushed. The earlier note that D-03 would start ahead of origin was wrong. Device tests are deferred to D-11 (see CLAUDE.md, Batch workflow), and no release build is made from `development` until D-11 passes.

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
- Device: **not run yet.** The steps (start-up with internet, airplane mode then Retry, logged in with bad network, fresh install, plus the smoke pass) are pending in `docs/device-test-backlog.md`. They run in the joint pass after D-03.

### Notes (found during D-01, not fixed)
- The `camera` dependency is now unused (pubspec unchanged). Remove it in D-10.
- Translation keys `connected` and `error_occurred` are missing from en.json and ar.json. NoInternetScreen uses `error_occurred`.
- NoInternetScreen says "No connection" for 5xx/unknown failures too. A separate server-error text could follow.
- No offline indicator exists after splash. The splash connectivity listener was the only subscriber, and it is cancelled in dispose.
- `ProfileModel.fromJson` throws when `identity_image_full_url` is missing (see code-traps.md).
- Backend docs (session): suspended and not-approved riders get 401 auth-001. A new login on another device invalidates the old token. So only 401 ends the session at splash, and no backend question is needed (no B-05).

### D-02 (2026-11-14)
- **Row 8:** `LogSanitizer` (lib/api/log_sanitizer.dart) masks the values of sensitive query keys (token, phone, number, password, otp, coordinates and similar).
  - `ApiClient` logs through it and logs only the keys of `query:`.
  - Exceptions are logged by type only.
  - GetX route logs use it through `logWriterCallback` in main.dart.
- **Row 9:** rider requests use the Bearer header only. The token is removed from every URI, query, body and multipart field: orders, profile, chat, wallet earning report, send-order-otp, change password, update-fcm-token and the session check. The only exception is the WebSocket location body, which cannot carry a header.
- **Rows 10, 11 and 12:** these calls use `handleError: false`:
  - latest-orders polling
  - record-location
  - geocode
  - single mark-read

  Mark-all-read is a user tap and keeps ApiChecker's single message.
- **Row 13:** if the first page of My Orders fails, `completedOrdersFailed` is set and the screen shows `NoInternetScreen(onRetry:)`. The page-1 load runs in try/finally, so the loader always stops. Later pages are unchanged (D-05).
- **Row 50:** chat search, the other chat GETs and the earning report use the `query:` map, which `Uri.replace` encodes.
- **Row 51:** the verification and reset-password routes are built with `Uri(queryParameters:)` through `RouteHelper._route`.
- **Changes beyond the plan:**
  - `SessionChecker` built `profileUri + token`. It now calls the plain path.
  - `ApiChecker.checkSession(response)`: a silent call still ends the session on a 401 and shows nothing for any other failure. `SessionChecker` only stops its timer on a 401, so it does not end the session.
  - `PhoneFormat.withPlus` (lib/helper/phone_format_helper.dart) fixes the `+` handling in verification_screen and new_pass_screen. new_pass_screen used to prepend `+`, which only worked because the route turned `+` into a space.
- **Tests:** 22 new, 33 total, 33 passed, 0 failed.
  - Fail on the old code by behaviour: T2, T3a, T3b, T3c, T3d, T4, T5a, T5b, T6, T7, T9, T10a, T10b (T10a and T10b were run through a temporary copy without the new import), and G5 (the old multipart body carried the token).
  - Fail on the old code at compile time only: T1, G4, T8a, T8b, T10c.
  - Guards: G1, G2, G3.
- **Analyze:** 0 issues.
- **Device:** **not run yet.** The steps are pending in `docs/device-test-backlog.md` (joint pass after D-03).

### Notes (found during D-02, not fixed)
- `getNavigationHandlerRoute` and `getChatRoute` put standard base64 (`+`, `/`, `=`) into query strings, where `+` decodes to a space (D-07).
- The `String token` parameter of `updateProfile` (repository, service and controller) is unused (D-09).
- Pull-to-refresh on the Requests tab is now silent offline. The old list stays.
- The WebSocket location body still carries the token, because a WebSocket cannot send the header. Revisit this if `websocket_status` is turned on (it is 0 live).
- **For D-03:** logout (and turning notifications off) sends `update-fcm-token` without `fcm_token`. The backend requires `fcm_token`, so the call fails silently and the server keeps the device token, which means a logged-out device can still get pushes. Consider `FirebaseMessaging.instance.deleteToken()` on logout. *(Fixed in D-03.)*

### D-03 (2026-11-14 to 2026-11-19)
- **Row 14 (login):**
  - `login` runs in try/finally with a double-tap guard. An exception gives one `error_occurred` toast, and the loader always stops.
  - A 200 without a non-empty `token` counts as a failure.
  - `saveUserToken(token, String? zoneTopic, String? vehicleTopic)` is awaited and saves all or nothing. Topics are written or removed first, the token last, and `apiClient.token` and the header are set only after the token is saved. A failure rolls back and rethrows.
  - Topics are null-safe: `''` and `No_topic_found` are never subscribed.
  - The FCM token update after login runs in the background and can no longer fail or block the login. `updateToken` sends nothing when FCM returns no token.
- **Row 15:** logout clears `apiClient.token` and keeps the current `X-localization` language.
- **Row 16 (option a):**
  - Remember-me keeps the phone only. `getUserPassword` is gone, and any stored password is purged (on sign-in screen init and when the number is saved).
  - The sign-in fields have `autofillHints` and an `AutofillGroup`, and `finishAutofillContext` runs after a successful login.
  - No new dependency.
- **Row 17:** the `block` push awaits the session and FCM cleanup, then opens sign-in. It has a re-entrancy guard.
- **Row 18:** `deleteDriver` has a double-tap guard and try/finally. It closes the confirm sheet only if it is still open (no bare `Get.back`), shows one message, and awaits the cleanup before sign-in.
- **Logout FCM (D-02 note):**
  - New `PushClient` (lib/helper/push_client.dart) wraps FirebaseMessaging.
  - `clearSharedData` clears the local session first: token, ignore list, address, topic keys, and the header (language kept).
  - Then it unsubscribes the saved topics and calls `deleteToken`, bounded at 5 s. The `update-fcm-token` call without `fcm_token` is gone.
  - On failure or timeout, `fcmCleanupPending` and `fcmCleanupTopics` are saved. The cleanup is retried at app start (splash, not awaited), on sign-in screen init, and as the first step of `updateToken`. The flag is cleared only after `deleteToken` succeeds.
  - The logout sheet now awaits the cleanup before sign-in.
  - Turning notifications off uses the same release.
- **Notifications off (fix within D-03):** `updateToken` does nothing while the notification setting is off, so splash, app start, the language change and login no longer register a token. Toggle-on saves the setting first and then registers.
- **Changes from the plan:**
  - The splash retry is not awaited, because `updateToken` waits for it before `getToken`. This avoids up to 5 s of extra splash delay offline.
  - `updateToken` skips the PUT when FCM gives no token.
  - The remember-me methods were renamed (`saveUserNumber`, `clearUserNumber`), so T11 fails on the old code at compile time only, not by behaviour as planned.
  - The notifications-off gate was added after the first implementation report.
  - The profile controller test now sets `Get.testMode = true`, so the old bare `Get.back()` can run in a test.
- **Tests:** 22 new, 55 total, 55 passed, 0 failed.
  - **Fail on the old code by behaviour** (`lib/` stashed, new tests run against it):
    - T1: `type 'Null' is not a subtype of type 'String'`
    - T2: the `getToken` error escapes
    - T3: the exception escapes
    - T4: the topic keys stay saved after the failed token write
    - T5: the header is `[null, null]` instead of `'ar'`
    - T6: one `update-fcm-token` call is sent
    - T9: the exception escapes from `deleteDriver`
    - T10: 2 delete requests instead of 1
    - T16: `getToken` is called while notifications are off (run against 6135f36)
  - **Fail on the old code at compile time only:** T7, T7b, T8, T8b, T11, T12, T13, T14, T15.
  - **Guards:** G1 (login 401), G2 (a saved token keeps the language), G3 (a failed delete stops the loader), G4 (toggle-on registers a token).
- **Analyze:** 0 issues.
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-03, steps 1–10) and run in D-11.

### Notes (found during D-03, not fixed)
- `ApiChecker._handleSessionExpired` (api_checker.dart) still calls `clearSharedData()` without await. It is the same pattern as row 17.
- The remember-me checkbox always starts unticked (`_isActiveRememberMe = false`), so a rider who does not tick it again loses the saved phone at the next login.
- The Postman note on rider login also mentions subscribing to `zone_{zone_id}_delivery_man`. The app does not do this. Check it against the API guide before D-07.
- The block push shows no message on the sign-in screen (a `logoutReason` could carry one).
- `android:allowBackup` is not set, so it defaults to true. SharedPreferences, including the auth token, are part of device backups.
- Splash called `updateToken()` even with notifications off, so the topics were re-subscribed at every start. *(Fixed in D-03.)*
- The working tree had `assets/image/change_password.png` and `assets/image/no_conversation.png` deleted outside D-03. Both are still referenced in `manager_assets.dart`. They were not staged or restored.

## Open backend questions

<!-- The only place new backend questions are recorded. Move a row to docs/backend-changes.md once the owner agrees. -->

| ID | Endpoint | Question / needed change | Why | Raised in | Status |
|---|---|---|---|---|---|
| B-01 | /api/v1/delivery-man/* (current-orders, latest-orders, all-orders, order, order-details, profile, remove-account, earning-report, message/*) | Can these accept the Bearer header only, so the app stops sending `?token=` in URLs and `token` in bodies? | Tokens in URLs end up in server, proxy and CDN logs (audit row 9) | D-00 | resolved in D-02: Bearer only (backend docs Doghri-App-Screens, rider R1-R7, 2026-10-14: the token query or body field is only a fallback). The only exception is the WebSocket location body, while `websocket_status` is 0 |
| B-02 | /api/v1/delivery-man/update-order-status | When `dm_picture_upload_status` is on, is a delivery photo mandatory? Does the server reject `delivered` without `order_proof`? | The app shows the photo section but never requires it (audit row 49) | D-00 | answered (same docs): `order_proof` is optional on the server (array, max 5, stored only with `delivered`). Requiring it in the app is an owner decision before D-09 |
| B-03 | /api/v1/delivery-man/wallet/withdrawals | Does the response include a total count for paging past `limit=20`? | Older withdrawals are never shown (audit row 42) | D-00 | answered (same docs): returns `total_size`; `limit` 1-50; `offset` is a page number starting at 1 |
| B-04 | /deliveryman-earning-report-invoice/{id} | What Content-Type and charset does the PDF response use? | The app saves decoded text as bytes, so a utf-8 charset would corrupt the file (audit row 41) | D-00 | open |
