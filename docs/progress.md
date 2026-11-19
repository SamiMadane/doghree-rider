# Progress

## Batch status

| Batch | Branch | Scope | Status | Merged |
|---|---|---|---|---|
| D-00 | docs/d-00-setup | CLAUDE.md, docs skeleton, audit | done | |
| D-01 | fix/d-01-startup | Audit rows 1, 2, 3, 4, 5, 7, 59 | merged, device tests pending (D-11) | 2026-11-14 |
| D-02 | fix/d-02-silent-network | Audit rows 8, 9, 10, 11, 12, 13, 50, 51 | merged, device tests pending (D-11) | 2026-11-14 |
| D-03 | fix/d-03-auth | Audit rows 14, 15, 16, 17, 18 + logout FCM (D-02 note) | merged, device tests pending (D-11) | 2026-11-19 |
| D-04 | fix/d-04-order-actions | Audit rows 19, 20, 21, 22, 23, 24, 25, 28, 29 | merged, device tests pending (D-11) | 2026-11-19 |
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

### D-04 (2026-11-19)
- **Backend check:** accept-order (R3 step 2), update-order-status (R4 step 1), GET order (R4 step 4) and order-details (R3 step 1). Every outcome is decided from the status and `errors[0].code` only (`order_action_result.dart`: `classifyAccept`, `classifyStatus`, `classifyFetch`, `riderMayMoveTo`).
- **Row 19:** `acceptOrder(OrderModel)` has no index. It removes the accepted card by id and creates the running list if it is null. It has a double-tap guard and try/finally.
- **Row 20:** the controller no longer navigates. `acceptFromCard` (order widgets) closes the confirm sheet with `Navigator.pop` on the tap itself, then acts on the outcome.
  - accepted → Order Details
  - offline (404 `active_status`) → one "you must be online" dialog and a silent profile refresh
  - taken (404 `order`, 409 `order_already_taken`) → the card is removed by id, one message, and a silent list refresh
  - refused (405) → the card stays and the server message is shown once
- **Row 21:** GET order is silent (`handleError: false` plus `checkSession`). It returns found, notFound (404 or 204) or failed.
  - A failed poll keeps the order on screen. The order is cleared only when another id loads.
  - notFound: Order Details shows one message and closes itself, including any sheet on top, never a route below.
  - A failed first load shows `NoInternetScreen` with Retry.
- **Row 22:** `updateOrderStatus` runs in try/finally with a double-tap guard. A 200 with a non-Map body no longer throws.
- **Row 23:**
  - 403 `invalid_status_transition` or `not_found`, or 404 `order`: the app's own message, then the running orders and the open order refresh.
  - 406 `error`: not delivered. The status and the photos stay, and the rider can retry.
  - 406 `otp`: the app's own message.
- **Approval note 1 (transition gate):** a move the local status refuses triggers one fresh GET. The request is sent if the fresh status allows it, or if the fetch failed (the server decides). It is blocked only if the fresh status refuses it too, or the order is gone.
- **Row 24:** proof photos belong to `_proofOrderId`, set by `prepareProofFor` when Order Details opens. They are kept when the same order reopens and cleared for another order. They are sent only with `delivered` of that order and cleared only after that delivery succeeds.
- **Row 25:** order-details is silent at the repository, and the controller shows exactly one message (404, offline or other).
- **Row 28:** the parcel branch calls `update()`.
- **Row 29:** the three delivery sheets no longer call `getProfile` and `getCurrentOrders` again after success.
- **New translation keys (en and ar).** `error_occurred` was missing (see the D-01 note). The `otp_not_matched` text was revised at closing.

  | Key | English | Arabic |
  |---|---|---|
  | `order_no_longer_available` | This order is no longer available | هذا الطلب لم يعد متاحاً |
  | `order_status_changed` | This order has changed. It has been refreshed | تغيّرت حالة هذا الطلب، وتم تحديثه |
  | `order_not_delivered_retry` | The order was not delivered. Please try again | لم يتم تسليم الطلب. يرجى المحاولة مرة أخرى |
  | `otp_not_matched` | The delivery code is wrong. Check it with the customer | رمز التسليم غير صحيح، تأكد منه مع الزبون |
  | `go_online_to_accept_orders` | You must be online to accept orders. Turn on Online from the home screen | يجب أن تكون متصلاً لتقبل الطلبات. فعّل حالة «متصل» من الشاشة الرئيسية |
  | `error_occurred` | Something went wrong. Please try again | حدث خطأ. يرجى المحاولة مرة أخرى |
- **Changes from the plan:**
  - The photos are bound through `prepareProofFor` in Order Details instead of passing the order id through the picker sheets.
  - The offline dialog uses the new key `go_online_to_accept_orders`, because the Arabic text of `make_yourself_online_first` talks about the internet.
  - A 401 shows no extra toast, because ApiChecker already ends the session.
  - The accept-row button height uses `Dimensions.h40`.
  - T17 was possible as a widget test.
  - T6 caught a bug during implementation: delivering another order cleared the photos. It was fixed before the report.
- **Tests:** 48 new, 103 total, 103 passed, 0 failed.
  - Test files: `order_action_result_test` 16, `order_repository_actions_test` 8, `order_actions_controller_test` 23, `delivery_sheet_refresh_test` 1.
  - **Fail on the old code by behaviour.** Adapted copies were run against the stashed `lib/`:

    | Test | Old-code result |
    |---|---|
    | T1 | `[3, 2]` instead of `[3, 1]` |
    | T2 | Null check operator used on a null value |
    | T3 | Null check (`Navigator.pop(Get.context!)`) |
    | T4 | Null check |
    | T5 | `isLoading` stays true |
    | R3 | `type 'String' is not a subtype of type 'int' of 'index'` |
    | T6 | Proof counts `[2, 2, 2]` |
    | R7 | `handleError` true |
    | T8 | 0 rebuilds |
    | T17 | 2 profile refreshes instead of 1 |

  - **Fail on the old code at compile time only:** C1–C4 (16 tests), R1, R2, R4, R5, R6, T7, T9, T10, T11, accept no-internet, T12, T13, T14, T15, T16a, T16b, T18, T19, T20.
  - **Guards:** G1 (one profile and one running-orders refresh after delivery), G2 (the body field is `status`), G3 (accept 200 moves the order to running). Their logic also holds on the old code, but their files do not compile against the old code, so they were not run there.
- **Analyze:** 0 issues.
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-04, steps 1–7) and run in D-11.

### Notes (found during D-04, not fixed)
- A non-parcel order in `accepted` shows "waiting for the store" instead of a picked-up slider, although R4 allows accepted → picked_up. This is a UX and owner decision.
- `order_slider_button` case 1 opens `ConfirmationBottomSheet` through `showCustomBottomSheet`. `Get.isBottomSheetOpen` does not see it, so with `back: true` the `Get.back` pops the sheet rather than the screen (code-traps.md).
- The `cancellation_dialogue_widget` success path still repeats `getProfile` and `getCurrentOrders` (not a delivery sheet, so outside row 29).
- `cancel_confirm_row` can send `confirmed`, which the server refuses under the store confirmation model. It is shown only for parcels, which send `handover`.
- The `OrderDetailsScreen.orderIndex` parameter is unused.
- `collect_money_delivery_sheet_widget.dart` is a byte-identical copy of `confirm_delivery_sheet_widget.dart` (same class name `ConfirmDeliverySheetWidget`). Clean up in D-10.
- The Arabic text of `make_yourself_online_first` says to connect to the internet. The handover slider still uses it.
- The push request sheet calls `getOrderWithId` for its own order. If Order Details is open on another order, the shown order is cleared until the next poll (existing behaviour, unchanged).

## Open backend questions

<!-- The only place new backend questions are recorded. Move a row to docs/backend-changes.md once the owner agrees. -->

| ID | Endpoint | Question / needed change | Why | Raised in | Status |
|---|---|---|---|---|---|
| B-01 | /api/v1/delivery-man/* (current-orders, latest-orders, all-orders, order, order-details, profile, remove-account, earning-report, message/*) | Can these accept the Bearer header only, so the app stops sending `?token=` in URLs and `token` in bodies? | Tokens in URLs end up in server, proxy and CDN logs (audit row 9) | D-00 | resolved in D-02: Bearer only (backend docs Doghri-App-Screens, rider R1-R7, 2026-10-14: the token query or body field is only a fallback). The only exception is the WebSocket location body, while `websocket_status` is 0 |
| B-02 | /api/v1/delivery-man/update-order-status | When `dm_picture_upload_status` is on, is a delivery photo mandatory? Does the server reject `delivered` without `order_proof`? | The app shows the photo section but never requires it (audit row 49) | D-00 | answered (same docs): `order_proof` is optional on the server (array, max 5, stored only with `delivered`). Requiring it in the app is an owner decision before D-09 |
| B-03 | /api/v1/delivery-man/wallet/withdrawals | Does the response include a total count for paging past `limit=20`? | Older withdrawals are never shown (audit row 42) | D-00 | answered (same docs): returns `total_size`; `limit` 1-50; `offset` is a page number starting at 1 |
| B-04 | /deliveryman-earning-report-invoice/{id} | What Content-Type and charset does the PDF response use? | The app saves decoded text as bytes, so a utf-8 charset would corrupt the file (audit row 41) | D-00 | open |
