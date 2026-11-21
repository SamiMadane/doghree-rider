# Progress

## Batch status

| Batch | Branch | Scope | Status | Merged |
|---|---|---|---|---|
| D-00 | docs/d-00-setup | CLAUDE.md, docs skeleton, audit | done | |
| D-01 | fix/d-01-startup | Audit rows 1, 2, 3, 4, 5, 7, 59 | merged, device tests pending (D-11) | 2026-11-14 |
| D-02 | fix/d-02-silent-network | Audit rows 8, 9, 10, 11, 12, 13, 50, 51 | merged, device tests pending (D-11) | 2026-11-14 |
| D-03 | fix/d-03-auth | Audit rows 14, 15, 16, 17, 18 + logout FCM (D-02 note) | merged, device tests pending (D-11) | 2026-11-19 |
| D-04 | fix/d-04-order-actions | Audit rows 19, 20, 21, 22, 23, 24, 25, 28, 29 | merged, device tests pending (D-11) | 2026-11-19 |
| D-05 | fix/d-05-order-lists-parsing | Audit rows 26, 27, 30, 52, 53 | merged, device tests pending (D-11) | 2026-11-20 |
| D-06 | fix/d-06-location-ringing | Audit rows 36, 37, 38, 39 | merged, device tests pending (D-11) | 2026-11-20 |
| D-07 | fix/d-07-notifications | Audit rows 6, 31, 32, 33, 34, 35, 54 | merged, device tests pending (D-11) | 2026-11-20 |
| D-08 | fix/d-08-wallet | Audit rows 41, 42, 43, 44 | merged, device tests pending (D-11) | 2026-11-21 |
| D-09 | fix/d-09-uploads-profile | Audit rows 45, 46, 47, 48, 49 | merged, device tests pending (D-11) | 2026-11-21 |
| D-10 | fix/d-10-cleanup | Audit rows 40, 55, 56, 57, 58, 60 + D-10 candidates and owner decisions Q1-Q7 | implemented, awaiting closing (device tests in D-11) | |
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
- `getNavigationHandlerRoute` and `getChatRoute` put standard base64 (`+`, `/`, `=`) into query strings, where `+` decodes to a space (D-07). *(Decided in D-07: decoding restores the `+`, so no change is needed. See the D-07 notes.)*
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

### D-05 (2026-11-20)
- **Backend check:** latest-orders, current-orders and notifications are bare arrays (R2 steps 1, 2, 6). `store_lat` and `store_lng` arrive as strings and every `store_*` key is null for an order with no store. order-details has three success shapes (R3 step 1). `all-orders` is **not in R1-R7**; its shape comes from the Postman example only (`total_size`, string `limit` and `offset`, `orders`), and `offset` is a page number from 1.
- **`JsonHelper`** (lib/helper/json_helper.dart): `asInt`, `asDouble`, `asString`, `stringList` and `mapList`. None throws. `mapList` gives null for anything that is not a List (a failure), `[]` for a real `[]`, and skips items that are not Maps or whose parse throws. It logs in debug only the list name and the number of skipped items, never content.
- **Rows 52 and 53:**
  - current-orders, latest-orders, notifications, zones, vehicles and order-details use `mapList`. A 200 with the wrong shape is a failure (null), so the old list stays and no loader hangs.
  - `PaginatedOrderModel` reads `total_size` with `asInt` and `orders` with `mapList`. `OrderModel` reads `id`, `details_count`, `store_lat`, `store_lng`, `module_type` and `order_type` defensively, and its string lists and `payments` through the helper.
  - The four `.cast<String>()` lines (profile, message, config module type, choice options) use `stringList`.
  - `ConfigModel` reads `module_config` only when it is a Map and `ModuleConfig` no longer indexes an empty `module_type`. Before, one bad `module_config` failed the whole config and splash showed the no-connection screen at every start.
- **Row 30:** `getModule` returns an empty `Module()` for a null or unknown type, an unloaded config or a broken entry. `OrderItemWidget` reads the flags with `?? false`.
- **Rows 26 and 27:** the controller owns the history paging.
  - More pages exist when `lastLoadedPage * 10 < total_size` and no page came back empty, so the filtered list length plays no part.
  - At most one page request is in flight. A failed page sets `historyPageFailed`, and only Retry continues. A late page after a refresh is dropped (generation counter). An order id that appears on two pages is shown once. The bottom loader stops on every path.
  - Every history page is silent (`handleError: false`). The failure shows in the footer (`HistoryPageFooterWidget`) with Retry.
  - A short list loads the next page by itself (`historyNeedsFill`) until the screen scrolls, the history ends or a page fails.
  - Removed `offsetList`, `offset`, `pageSize`, `setOffset` and `showBottomLoader` from `OrderController`.
- **New translation key (en and ar):**

  | Key | English | Arabic |
  |---|---|---|
  | `load_more_failed` | Couldn't load more orders | تعذّر تحميل المزيد من الطلبات |
- **Changes from the plan:**
  - `ConfigModel` `module_config` guard (above) was added after test S3 showed a string value failed the whole config.
  - `JsonHelper.asInt` was fixed during the tests: `NaN.toInt()` throws, so non-finite numbers now give null.
  - The D-02 guard G3 ("page 2 keeps `handleError: true`, D-05") was replaced by T7b, because D-05 makes page 2 silent on purpose.
- **Tests:** 49 new, 152 total, 152 passed, 0 failed. Analyze: 0 issues.
  - Files: `json_helper_test` 8, `parsing_shapes_test` 21, `order_history_paging_test` 13, `splash_module_test` 7, plus T7b in `silent_calls_test`.
  - **Fail on the old code by behaviour.** The new tests were run against the stashed old `lib/`; the paging tests through a temporary copy that used the old API (`showBottomLoader` then `getCompletedOrders(page)`), which was deleted afterwards:

    | Test | Old-code result |
    |---|---|
    | P1 | `paginate` stays true |
    | P2 | Null check operator used on a null value |
    | P3 | FormatException escapes |
    | P4 | requested `[1, 2]` instead of `[1, 2, 2]` |
    | P5 | `[1, 2, 2, 3]` instead of `[1, 2, 3]` |
    | P6 | `[9, 3, 4]` instead of `[9]` |
    | R1, R3, R4 | `type '(dynamic) => void' is not a subtype of type '(String, List<dynamic>) => void'` (a Map body was iterated) |
    | R2, R5 | `Class 'String' has no instance method 'forEach'` |
    | R6 | `type 'String' is not a subtype of type 'Map<String, dynamic>'` |
    | R7, T7b | `handleError` true |
    | R8 | `type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'` |
    | M1, M2, M4 | `The method 'cast' was called on null` |
    | M3a | `The method 'cast' was called on null` |
    | M3b | `RangeError (length): Valid value range is empty: 0` |
    | M5 | `type 'String' is not a subtype of type 'int?'` |
    | M6 | `type 'double' is not a subtype of type 'String?'` |
    | S1 | `type 'Null' is not a subtype of type 'Map<String, dynamic>'` |
    | S2, S3 | `The method '[]' was called on null` |
    | W1, W1b | the same `Null` is not a `Map` error, thrown while the row builds |

  - **Fail on the old code at compile time only:** J1–J7 (no `JsonHelper`), and P7–P11 (no `loadNextHistoryPage`, `retryHistoryPage`, `historyPageFailed`, `hasMoreHistory`, `historyNeedsFill`).
  - **Guards** (pass on the old code too): G1, G2, G3, G4, G8, G9, G12 and M7. G7, G10 and G11 are guards that only compile against the new code.
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-05, steps 1–5) and run in D-11.

### Notes (found during D-05, not fixed)
- **Watch in D-11:** a skipped item in current-orders hides a running order from the rider. `mapList` skips an item that does not parse and logs only the count. If a rider reports a missing running order, check this first.
- `getModuleConfig` has the same crash as `getModule` but no callers. Remove it in D-10 (row 56).
- Other unguarded `.forEach` and forced reads outside rows 52 and 53: the lists in `order_details_model` (variation, add_ons, category_ids, food_variations, variations, choice_options), `conversation_model`, `earning_report_model`, the config `language` list, zone `coordinates` and address `zone_data`.
- The notification sort forces `updatedAt!`, so one notification without `updated_at` throws in `getNotificationList`.
- On first load, Requests, Running orders, Notifications and Zones still show a spinner after a failure, with no NoInternet state (unchanged).
- `all-orders` is missing from Screens R1-R7. The Postman example nests a `store` object, while Screens R2 and the app use flat `store_*` keys. The app follows Screens.
- The `_MetaTag` unit/veg logic in `OrderItemWidget` still forces `itemDetails!` and `.price!` (outside row 30).

### D-06 (2026-11-20)
- **Backend check:** record-location-data (R2 step 4) has no validator and stores whatever it gets, so the app sends only a real position. `websocket_status` is 0 live (Screens config), so the WebSocket path is made safe, not redesigned. The server notification channel is untouched: the manifest default (`doghree_rider`), `NotificationHelper.channelId` and the local notification channel stay as they were. The name `6ammart` comes from the backend API guide and is not used by the app.
- **Row 36 (ringing never continues with no pending request):** `OrderRinging` (lib/helper/order_ringing.dart) stops the foreground service. It is idempotent, silent and never throws.
  - Stops: `main()` at start-up; `OrderRingingObserver` on every app resume (app level, so it works on splash and sign-in too); the two notification tap handlers; `DashboardScreen` init and the switch to the Requests tab; `acceptOrder` (accepted and taken); `ignoreOrder`; `getLatestOrders` when the pending list is empty; `AuthRepository.clearSharedData` (logout, block, session expiry and delete account all end there), first and never blocking; swipe-away of the service notification (Android 14+).
  - Cap: `MyTaskHandler` stops the service after 12 rings (60 s). A new push restarts the service with a fresh count. This is the only guard for a backgrounded app that never learns the order was taken.
  - The player is stopped before it is disposed.
- **Row 37:** the title is built by `OrderRinging.title`. An assign push without an id reads "You have been assigned a new order", never "(null)". The service channel is now `doghree_rider_ringing` ("Order ringing"). The old `stackfood` channel is deleted once at start-up by `retireLegacyChannel`, which accepts only that exact id and never runs while a service runs. Side effect: settings the rider changed on the old channel are gone and the new one starts with defaults.
- **Row 38:** `ProfileService.currentPositionOrNull` checks GPS and permission, reads the position with an 8 s limit and returns null for any failure or unusable fix (null, NaN, infinite, out of range, exactly 0/0). `recordLocation` skips the tick silently (nothing sent, last real position kept), has an in-flight guard, never throws, and reads the config null-safely (no config means the HTTP path). It recovers by itself on the next tick.
- **Row 39:** `recordWebSocketLocation` returns a bool and never throws. A missing URI, port or key opens nothing. It waits for `ready` (5 s), swallows late stream errors, always closes the socket, and clears the token from the body afterwards. One socket per tick remains (not redesigned).
- **Changes from the plan:**
  - `ProfileRepository` takes an optional config reader and socket factory (used only by tests), so the WebSocket path could be tested.
  - The WebSocket body token is cleared after the send (not in the plan).
  - The ring counter runs inside `_playAudio`, so the first ring at start-up counts toward the 12.
  - The old `webSocketStatus` null case is covered by the no-config test (L3: no `SplashController` registered). A registered controller with a null field was not built as a test.
  - Extra tests beyond the plan: R3b, R4b, L6, L7, G5, G6, R7b.
  - The old-code check for L1 used the `MissingPluginException` that the test environment raises for the geolocator call, which is the same failure as GPS off.
- **Tests:** 34 new, 186 total, 186 passed, 0 failed. Analyze: 0 issues.
  - Files: `order_ringing_test` 12, `location_record_test` 10, `websocket_location_test` 5, `logout_ringing_test` 2, plus 5 in `order_actions_controller_test` (R4, R4b, R5, R6, G6).
  - **Fail on the old code by behaviour** (adapted copies run against the stashed `lib/`, then deleted):

    | Test | Old-code result |
    |---|---|
    | L1 | `MissingPluginException(No implementation found for method getCurrentPosition on channel flutter.baseflow.com/geolocator)` escapes from `recordLocation` |
    | W2 | `"SplashController" not found` escapes from `recordWebSocketLocation` |
    | R8 | the old title expression `(${orderId.toString()})` gives "(null)". The old expression was reproduced inline, because the old code has no callable title function |

  - **Fail on the old code at compile time only** (the old code has no seam): L2–L7, W1, W3, W4, R1–R7, R4b, R9–R13. They test decisions that did not exist before.
  - **Guards:** G1 (a real position is sent once), G2 (no token field over HTTP), G3 (a good socket tick), G4 (the server channel constants), G5 (usable-fix boundaries), G6 (a failed refresh does not stop the ringing).
- **Proven only by unit tests of the decisions, device needed in D-11:** the foreground service really stopping and the sound ending (row 36 events and the cap), the real notification title and the channel list in Android settings (row 37), and real GPS and permission changes (row 38). The WebSocket path cannot run live (`websocket_status` is 0), so row 39 stays unit-tested.
- **Device:** **not run.** Steps are in `docs/device-test-backlog.md` (D-06, steps 1–12).

### Notes (found during D-06, not fixed)
- **Resume race:** a request that arrives at the same moment as a resume is visible in the Requests tab even if its ringing was stopped by that resume.
- A backgrounded app cannot learn that another rider took the order (no push for it in R2/R3 of the screens file). Only the 60 s cap ends that ringing.
- The foreground push handler in `DashboardScreen` runs `int.parse(message.data['order_id'].toString())` for request and assign pushes, which throws when `order_id` is missing (D-07, with the other push rows). *(Fixed in D-07, row 32.)*
- The foreground-service title and text are hard-coded English: the background isolate has no GetX translations.
- The WebSocket body still carries the token (a socket cannot send a header). Revisit if `websocket_status` is switched on.

### D-07 (2026-11-20)
- **Backend check:**
  - Push types are `new_order`, `order_status`, `order_request`, `message` and `withdraw` (API guide v3).
  - The withdraw push sends `order_id: ''` (Screens R6).
  - R2: refresh the board on a push and never deep-link the pushed order.
  - The notifications list is a bare array and `200 []` on exceptions (already handled in D-05).
  - Rider chat is not in R1-R7, and Postman has no saved chat response.
- **Rows 35 and 6:** `NotificationRouter` (lib/helper/notification_router.dart) is the only type-to-target map. The local tap, onMessageOpenedApp and splash all call `NotificationRouter.open`.

  | Push | Opens |
  |---|---|
  | `order_status` or `assign` with an id | Order Details |
  | `order_status` or `assign` without an id | My Orders |
  | `new_order`, `order_request`, `unassign` | the Requests tab |
  | `message` with an id | that chat |
  | `message` without an id | the conversation list |
  | `withdraw` | Wallet |
  | `general`, `cash_collect`, unknown | Notifications |
  | `block` | sign-in |
  | `unblock`, `otp`, no body, or logged out | nothing |

  - Tabs and sign-in use `offAllNamed`, so only one Dashboard exists.
  - A cold start puts the dashboard under the target, so back never returns to splash.
  - Splash runs either the push target or the default routing, exactly once (`coldStartPlan`). A failed open falls back to the default routing.
- **Rows 31 and 34:**
  - Push ids are read with `NotificationRouter.validId` (missing, `''`, non-numeric or ≤ 0 gives null). `NotificationBodyModel.fromJson` reads its ids with `JsonHelper`.
  - `/order-details` with a bad id opens My Orders.
  - `/chat-screen`: a bad `conversation_id` is null, and a broken body opens the conversation list.
  - `/navigation-handler`: a broken body gives null.
  - The base64 encoding is unchanged.
- **Row 32:** the dashboard listener uses `ForegroundOrderPush.fromData`. A request or assign push always refreshes current and latest orders, and shows the sheet only with a real id.
- **Row 33:** a chat push reads `messageModel?.conversation?.id`. `chatPushAction` refreshes the open chat only when both ids match. Otherwise (still loading, another chat, or a bad id) the rider gets the notification.
- **Row 54:** `ChatRepository.getMessages` parses only a Map body. `MessageModel` reads `messages` with `mapList` (never null) and its numbers with `asInt`. An empty list still gives a model.
- **Approval notes:**
  - `unblock` opens nothing for a logged-in rider (it was sign-in). `block` still opens sign-in.
  - The cold-start decision is pure and tested (C1, C2).
- **Changes from the plan:** `chatPushAction` lives in `NotificationRouter`, not in `NotificationHelper` (pure, no Firebase). Extra tests beyond the plan: N4b, N10, R13, R14, F1, F2, P1.
- **Tests:** 35 new, 221 total, 221 passed, 0 failed. Analyze: 0 issues.
  - Files: `notification_router_test` 21, `notification_push_test` 4, `route_helper_test` +6, `chat_messages_parsing_test` 4.
  - **Fail on the old code by behaviour** (stashed `lib/`):

    | Test | Old-code result |
    |---|---|
    | N1 | `FormatException: Invalid radix-10 number (at character 1)` |
    | N2 | `NoSuchMethodError: Class 'int' has no instance getter 'isNotEmpty'` |
    | N3 | `FormatException: Invalid radix-10 number (at character 1)` |
    | N4 | `FormatException: Invalid radix-10 number (at character 1)` |
    | N4b | `FormatException: Invalid character (at character 11)` |
    | N5 | `type 'String' is not a subtype of type 'int' of 'index'` |
    | N6 | `NoSuchMethodError: The getter 'isEmpty' was called on null` (messages null) |
    | N7 | `NoSuchMethodError: Class 'String' has no instance method 'forEach'` |
    | N10 | `type 'String' is not a subtype of type 'int?'` |
    | N8 (old expression reproduced inline) | `int.parse` throws FormatException |
    | N9 (old expression reproduced inline) | `messageModel!` null check throws |

  - **Fail on the old code at compile time only:** R1–R14, C1, C2, F1, F2 and P1 (no `NotificationRouter` or `ForegroundOrderPush`).
  - **Guards** (pass on the old code too): G1 (withdraw gives no order id), G2 and G3 (base64 round trip with `+`), G4 (empty messages give a model), G5 (a numeric order id still opens the order).
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-07, steps 1–8) and run in D-11.
- **Status:** merged into `development` (2026-11-20), device tests pending (D-11).

### Notes (found during D-07, not fixed)
- `NotificationController.handleNotificationTap` (the in-app notification list) keeps its own type map. `unassign` opens My Orders there and Requests from a push.
- `ConversationsModel.fromJson` throws on a non-Map body (chat list and search). The push-triggered `getConversationList` uses `handleError: true`, so a chat push while offline can show a toast.
- `ChatScreen` forces `notificationBody!` in initState and `conversation!.receiver!` in its app bar.
- `ChatController.getMessages` with offset > 1 and a null `_messageModel` crashes.
- A failed first chat load has no retry state.
- A cold start from a push skips the `updateToken()` that default routing runs. Review it in D-10 or D-11.
- Tapping a `block` push only opens sign-in. The session is cleared by the foreground listener or the next 401, not by the tap.
- `assign`, `unassign`, `block`, `unblock`, `otp` and `cash_collect` are not in the documented push types. They are still handled.
- D-02 base64 note, decided in D-07: no change needed.
  - Both routes put `+` back (`replaceAll(' ', '+')`) and Dart's decoder reads both alphabets, so the round trip works.
  - Moving to `base64Url` would be cosmetic.
  - Guards G2 and G3 lock in the current behaviour.

### D-08 (2026-11-21)
- **Backend check:**
  - Screens R5 and R6. `GET wallet` is the UI contract (`can_request_withdraw`, `withdraw_block`). Money fields are JSON numbers rounded to 2 decimals, and the app recomputes nothing.
  - `wallet/withdrawals`: `limit` 1-50, `offset` is a page number from 1, `total_size`, newest first (B-03).
  - `wallet/withdraw` 403 has two families of code: field names, and domain codes (R6 table) plus `rider_withdraw_account_required` (R6 text).
  - The store-transfer delivery-fee routes answer 410. The app calls neither of them (grep), and nothing in the wallet retries by itself.
  - The invoice route is in no backend file (Screens, API guide, Postman). B-04 stays open.
- **Row 41:**
  - `ApiClient.getBytes`:
    - always silent, 60 s timeout
    - normal headers (Bearer), no token in the query
    - logs the path, the query keys and the byte length only
  - The pure `handleBytesResponse` keeps `bodyBytes` untouched on 200, and decodes an error body leniently for the server message.
  - The controller writes the bytes only when they start with `%PDF-`. Writing and opening go through `InvoiceSaver` (`FileInvoiceSaver` by default).
  - One message per tap. Double-tap guard. try/finally.
- **Row 42:** the controller pages `wallet/withdrawals` with limit 20 (`WithdrawalsPage`):
  - more pages exist while `page*20 < total_size` and no page came back empty; a missing `total_size` ends the paging
  - at most one request is in flight
  - pull-to-refresh reloads page 1 and bumps a generation counter, so a late page is dropped
  - ids are de-duplicated
  - a failed page waits for Retry
  - The footer moved to `lib/common/widgets/history_page_footer_widget.dart` (now used by two features), with an optional `failedText`.
  - The scroll controller is disposed, and a short list fills itself.
  - The wallet preview's See all uses `total_size`.
- **Row 43:** `GET wallet` and `GET withdrawals` are silent (`handleError: false` plus `checkSession`) and keep the last known values on any failure. `classifyWithdraw` uses the status and the **first recognized** `errors[].code` in list order:

  | Input | Outcome | Silent refresh |
  |---|---|---|
  | 200 | sent (one success toast) | wallet and withdrawals |
  | 403 field codes (`amount`, `fields`, `withdrawal_method_id`, `note`, `account_id`) | invalidInput | none |
  | 403 `withdraw_amount` | invalidInput | wallet only |
  | 403 `withdraw_weekly_limit`, `withdraw_no_balance`, `withdraw_minimum`, `withdraw_insufficient_balance` | blocked | wallet and withdrawals |
  | 403 `withdraw`, `rider_withdraw_account_required` | accountProblem | wallet |
  | 403 with an unknown code | failed | wallet and withdrawals |
  | 401 | sessionEnded (no inline text) | none |
  | offline | localized no-internet text | none |
  | 410, 5xx, other | failed | none, never retried |

  - The rider sees one inline message: the server text, or a local key for that outcome.
  - **`withdraw_amount` decision:** R6 only says "write an amount greater than zero". It does not say the balance is unaffected, so the wallet is refreshed silently as well (approval note 3).
- **Row 44:** `deleteWalletAccount` ignores a second tap while busy and runs in try/finally. `classifyDeleteAccount` decides the message:
  - 200: one toast and a silent refresh
  - 404 `account`: the server text and a refresh
  - 401: no toast
  - offline: the no-internet text
  - an exception: `error_occurred`

  The confirm sheet ignores a second tap.
- **New translation keys (en and ar):**

  | Key | English | Arabic |
  |---|---|---|
  | `wallet_load_more_failed` | Couldn't load more withdrawal requests | تعذّر تحميل المزيد من طلبات السحب |
  | `invoice_download_failed` | Couldn't download the statement. Please try again | تعذّر تنزيل الكشف. يرجى المحاولة مرة أخرى |
- **Changes from the plan:**
  - `account_id` is also treated as a field code. It is a request field and needs no separate rule.
  - Extra tests beyond the plan: B6 (Bearer header, no token, log length only), B7, B8, B9, K1, K2, P8, P9, W6, C-multi and C-codes.
  - `FakeApiClient` gained a `getBytes` override.
- **Tests:** 63 new, 284 total, 284 passed, 0 failed. Analyze: 0 issues.
  - Files: `wallet_action_result_test` 20, `wallet_repository_test` 11, `wallet_controller_test` 32.
  - **Fail on the old code by behaviour.** Adapted copies were run against the stashed `lib/`, then deleted:

    | Test | Old-code result |
    |---|---|
    | B1 | `API ✖ … → FormatException`, statusCode `0` instead of `200` (the utf-8 decode of the PDF bytes throws) |
    | P1 | uri `…/wallet/withdrawals?limit=20&offset=2` with no query map, instead of the query `{limit: 20, offset: 2}` |
    | S1 | `handleError` true |
    | S2 | `handleError` true |
    | S3 | inline text `Connection to API server failed due to internet connection` instead of the localized no-internet text |
    | D1 | 2 deletes instead of 1 |
    | D2 | `Exception: x` escapes, `accountBusy` stays true |

  - **Fail on the old code at compile time only:** every C-* classifier test, P2–P9, R1–R3, B2–B9, W1–W7, K2, D3–D6. The old code has no classifiers, no `WithdrawalsPage`, no `InvoiceDownload` or `InvoiceSaver`, and no `toast` seam.
  - **Guards** (their logic also holds on the old code; they were not run there): GB1 (a PDF without a charset round-trips byte for byte, because latin1 maps one to one), GM1 (money is read as sent), GW1 (`withdrawBusy` resets after an exception), G410 (a failed page is not requested again by itself), K1 (the old `getWallet` also kept the wallet on a null result).
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-08, steps 1–9) and run in D-11.
- **Status:** merged into `development` (2026-11-21), device tests pending (D-11). Rows 41–44 are closed on the app side. B-04 stays open, and the on-device balance and amount checks stay a D-10 candidate (notes below).

### Notes (found during D-08, not fixed)
- **D-10 candidate:** the device repeats server withdraw rules. The withdraw sheet refuses an amount above `availableBalance` (`wallet_withdraw_exceeds`), and `_WithdrawButton` refuses when `availableBalance <= 0`. With stale wallet data this can block a request the server would accept. R5 and R6 say the screen follows `can_request_withdraw` and `withdraw_block` only, and the server answers `withdraw_insufficient_balance` / `withdraw_no_balance` itself.
- R6: the successful withdraw response already carries a fresh `wallet`, so the app's second `GET wallet` after success is not needed.
- `saveWalletAccount` on a 401 shows the session sheet and also sets an inline account error.
- `saveWalletAccount` still calls `showCustomSnackBar` directly, not through the controller's `toast` hook.
- A failed first wallet load shows the account card refresh icon, not `NoInternetScreen`.
- The invoice route (`/deliveryman-earning-report-invoice/{id}`) is not under `/api/v1` and is not documented. If it does not accept the Bearer header, it may answer with an HTML login page. The app now refuses that (not a PDF), but the download would never work (B-04).

### D-09 (2026-11-21)
- **Backend check:**
  - update-order-status (Screens R4 step 1): `order_proof => 'array|max:5'`, no required, mime or size rule, stored only with `delivered`. **The server does not require a photo**, so owner decision B-02 (proof optional) needs nothing from the server.
  - Photos and the status are one request, and there is no separate photo endpoint.
  - GET order returns the formatted order with `order_proof_full_url`.
  - API guide v3: uploads are whitelisted to jpg, jpeg, png, webp, pdf and stored by the detected content type.
  - update-profile is not in Screens R1-R7. Postman gives the fields; the image rules are undocumented.
  - **Approval note 1 (empty body):** the docs do not say what update-order-status answers when PHP drops an oversize body. The documented validation envelope for a missing required field is 403 `{"errors":[{"code":"order_id",…}]}` (Screens, error shape 1). That shape is handled. 405 (lost `_method`) and a Laravel `ValidatePostSize` 413 are possible but undocumented; 413 is handled by status, and 405 is left as a plain failure (B-04 questions 7–11).
- **Row 45:** `UploadFormats.sniff` (lib/helper/upload_format.dart) reads the first 16 bytes. `postMultipartData` labels each part by content (unknown → `application/octet-stream`) and fixes the filename extension to match.
- **Row 46:**
  - `ImageUploadRules` (lib/helper/image_upload_rules.dart): one constant `maxImageBytes` (2 MB, also used by registration), jpeg/png/webp only, unreadable for a missing or empty file. Never throws.
  - `classifyPickError` maps plugin codes (`camera_access_denied`, `photo_access_denied`, `no_available_camera`) to one message. A cancel is silent.
  - The profile photo goes through `acceptProfileImage`; a refused photo keeps the old one. One picker at a time.
  - The proof picker (`pickPrescriptionImage`) is `Future<void>` with a guard, try/catch and the same rules. `Get.isDialogOpen!` is gone.
- **Row 47:** `updateProfile` sends only non-null fields, has no `token` parameter (D-02 note), sends the `image` part only when picked, and calls `checkSession`.
- **Row 48:** `updateUserInfo` has a double-tap guard and try/finally. One message per outcome (server text, `profile_updated`, no-internet text, `error_occurred`, nothing on 401). Success copies only the edited fields into the loaded profile, so id, online state and wallet fields stay.
- **Row 49 (B-02, proof optional):**
  - The photo section says the photo is optional. Delivery is never gated.
  - Before `delivered`, unreadable photos are dropped (`delivered_some_photos_skipped` on success).
  - A `delivered` request with photos that fails with 413, 403 `order_id`/`status`, 5xx, 0 or 1 is never resent automatically. One silent `GET order` decides (`classifyProofFailure`):

    | Fresh order | Outcome |
    |---|---|
    | delivered | success path; `order_delivered` if `hasProofImages`, else `delivered_photos_not_saved` |
    | picked_up after 413 / 403 field code | `DeliverWithoutPhotosDialog`; Yes resends the same body object once with no files |
    | picked_up after 5xx | `order_not_delivered_retry`, photos kept |
    | picked_up after 0 or 1 | `delivery_unconfirmed`, photos kept |
    | another status or not found | D-04 order-changed path |
    | fetch failed | `delivery_unconfirmed`, photos kept |
  - A `delivered` without photos, and 403/404/406 server decisions, keep the D-04 behaviour exactly.
- **New translation keys (en and ar):**

  | Key | English | Arabic |
  |---|---|---|
  | `please_upload_lower_size_file` | This photo is too large. Please choose a photo under 2 MB | حجم الصورة كبير. يرجى اختيار صورة أقل من 2 ميغابايت |
  | `photo_format_not_supported` | This photo format is not supported. Use a JPG, PNG or WEBP photo, or take a new one with the camera | صيغة الصورة غير مدعومة. استخدم صورة JPG أو PNG أو WEBP، أو التقط صورة جديدة من الكاميرا |
  | `camera_permission_denied` | Camera access is off. Allow it in your phone settings | الوصول إلى الكاميرا غير مسموح. فعّله من إعدادات الهاتف |
  | `gallery_permission_denied` | Photo access is off. Allow it in your phone settings | الوصول إلى الصور غير مسموح. فعّله من إعدادات الهاتف |
  | `no_camera_available` | No camera is available on this device | لا توجد كاميرا متاحة على هذا الجهاز |
  | `image_pick_failed` | Couldn't use this photo. Please try again | تعذّر استخدام هذه الصورة. يرجى المحاولة مرة أخرى |
  | `proof_photo_optional_hint` | Optional. You can deliver without a photo | اختيارية. يمكنك التسليم بدون صورة |
  | `order_delivered` | The order was delivered | تم تسليم الطلب |
  | `delivered_photos_not_saved` | The order was delivered, but the photos were not saved | تم تسليم الطلب، لكن لم يتم حفظ صور إثبات التسليم |
  | `delivered_some_photos_skipped` | The order was delivered. Some photos could not be attached | تم تسليم الطلب. تعذّر إرفاق بعض الصور |
  | `delivery_unconfirmed` | We couldn't confirm the delivery yet. The order will refresh by itself | تعذّر تأكيد التسليم حتى الآن. سيتم تحديث الطلب تلقائياً |
  | `photos_upload_failed_deliver_without` | The photos could not be uploaded. Deliver the order without photos? | تعذّر رفع الصور. هل تريد تسليم الطلب بدون صور؟ |
  | `deliver_without_photos` | Deliver without photos | التسليم بدون صور |
  | `profile_updated` | Your profile was updated | تم تحديث ملفك الشخصي |
- **Changes from the plan:**
  - `OrderActionResult` carries every `errors[].code` (`codes`), needed for the 403 field-code rule.
  - `OrderModel.hasProofImages` reads `order_proof_full_url` through `JsonHelper.stringList` (approval note 6).
  - In `updateUserInfo` the screen close (`Get.back`) is in its own try, so a navigation failure never turns a saved profile into an error message.
  - An unreadable picked photo gives `image_pick_failed`, not the format text.
  - The D-04 tests T6 and T13 now bind real JPEG files, because unreadable photos are dropped since D-09.
  - Extra tests beyond the plan: M3, I7, R3a/R3b (R3 split), U4–U6, D2d, D7–D10, G6, J6.
- **Tests:** 67 new, 351 total, 351 passed, 0 failed. Analyze: 0 issues.
  - Files: `upload_rules_test` 21, `profile_update_test` 13, `delivery_proof_test` 33.
  - **Fail on the old code by behaviour** (adapted copies run against the stashed `lib/`, then deleted):

    | Test | Old-code result |
    |---|---|
    | M1 | content type `image/jpeg` for a HEIC file |
    | M2 | content type `image/png` for JPEG bytes named .png |
    | R1 | Null check operator used on a null value |
    | U1 | `isLoading` true after the exception |
    | U2 | 2 update requests instead of 1 |
    | U3 | profile id null instead of 7 |
    | D1 | the missing file sent as well: 2 paths instead of 1 |
    | D3 | toast `No internet connection / Please check your connection and try again` instead of `order_delivered` |

  - **Fail on the old code at compile time only:** F1–F7, I1–I7, E1–E4, R2, R3a, R3b, U4–U6, P1, P2, D2, D2b, D2c, D2d, D4–D10, C1–C5, J1–J6, K1–K4 (no `UploadFormats`, `ImageUploadRules`, `classifyPickError`, `classifyProofFailure`, `hasProofImages`, `acceptProfileImage`, `pickImageFn`, `confirmDeliverWithoutPhotos` or `DeliverWithoutPhotosDialog`; the old `updateProfile`/`updateUserInfo` take a token).
  - **Guards** (their logic also holds on the old code; their files do not compile against it): M3, G1, G2, G3, G4, G5, G6.
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-09, steps 1–8) and run in D-11.
- **Status:** merged into `development` (2026-11-21), device tests pending (D-11). Rows 45–49 are closed on the app side. B-04 stays open, now with the upload-limit questions 7–11. The D-10 candidates stay open: the phone field that is never sent (below), the on-device balance and amount checks (D-08 notes), and the `stash@{0}` review (below).

### Notes (found during D-09, not fixed)
- **D-10 candidate:** review `stash@{0}` ("WIP on development: 8a04c88", from before D-09). It was left untouched in D-09; decide with the owner whether to keep or drop it.
- **D-10 candidate:** Edit Profile shows a phone field, but the phone is never sent (Postman lists no phone field), and the "nothing changed" check compares it. A phone-only edit reports success and changes nothing.
- On iOS the proof "add photo" opens the gallery directly, with no camera option (`DeliveryImagesSection`).
- `please_upload_lower_size_file` was used by registration but missing from en/ar. Added in D-09.
- A 405 on `delivered` with photos (if the server answers that for a dropped body) is a plain failure: the photos stay and the rider can remove them and retry. Revisit when B-04 questions 7–11 are answered.
- Registration (`AuthService.pickImageFromGallery`, `ProfileService.pickImageFromGallery`) still has its own size checks; row 56 (D-10).
- `flutter test` and `flutter analyze` rewrite the macOS and Windows generated plugin files with line-ending-only changes. They were restored and are never committed.

### D-10 (2026-11-21)
- **Scope:** audit rows 40, 55, 56, 57, 58, 60, the D-10 candidates from earlier batches, and the owner decisions Q1, Q2, Q4 (Q3 left as is). Every deletion was checked by grep over `lib/`, `test/`, pubspec, routes and string references, then by analyze.
- **Row 40:** removed `AddressController.getZone` and its service, repository and interface methods, the fields only it wrote (`loading`, `isLoading`, `inZone`, `zoneID`) and `AppConstants.zoneUri`. `ZoneResponseModel` stays (`address_model.dart` imports it).
- **Row 55:** removed the second "/// Service" block in `get_di.dart` (11 concrete registrations). No code finds a concrete service type; every controller takes the interface.
- **Row 56:** removed the old pickers (`AuthController.pickDmImageForRegistration`, `ProfileController.pickProfileImage` and `pickImage`, `pickImageFromGallery` in both services and interfaces, `ImagePickerHelper.pickProfileImage` and `pickNormalImage`). The broken size check (`length().then` result ignored) went with them; the live pickers use `ImageUploadRules` since D-09. Also removed `SplashController.getModuleConfig`, `storeCategoryID`, `storeType`, `firstTimeConnectionCheck` with its setter, and `NotificationHelper.showTextNotification` (no caller, no isolate entry point, no string reference).
- **Row 57:** removed the 110 commented-out lines of the old ApiChecker.
- **Row 58:** removed the tracked stray files `bash.exe.stackdump`, `script.dart`, `unused_related.txt` and `$null` (a `flutter pub deps` output committed by a PowerShell redirect), and the `args` dev dependency that only `script.dart` used (`args` stays in the lock as a transitive package).
- **Row 60:** the bottom nav moved, unchanged, to `lib/features/dashboard/widgets/dashboard_bottom_nav_widget.dart`. Its sizes come from `Dimensions` (`w16`, `h10`, new `h76`, `r24`, `r18`, `h6`). The children (`bottom_nav_item_widget`, `bottom_nav_road_indicator`) keep their raw sizes (note below).
- **Candidates:**
  - Deleted `collect_money_delivery_sheet_widget.dart`, a byte-identical, never-imported copy of `confirm_delivery_sheet_widget.dart`.
  - Removed the `camera` dependency (D-01 note). Lock diff: only `camera`, `camera_android_camerax`, `camera_avfoundation`, `camera_platform_interface`, `camera_web` and `stream_transform` (used only by camera) are gone, plus `args` direct dev → transitive (row 58). No version changed. `NSCameraUsageDescription` and the CAMERA permission stay. Merged debug manifest (`flutter build apk --debug` before and after): the permission lines are identical; the only differences are the plugin's `<uses-feature android:name="android.hardware.camera.any" />` (no `required` attribute, so it counted as required) and CameraX's `MetadataHolderService` entry, both gone. Google Play still infers a required camera from the CAMERA permission, so device filtering should be about the same. Check the Play Console device catalog at the next release.
  - Removed the unused `OrderDetailsScreen.orderIndex` and its 4 call-site arguments (D-04 note).
  - `image_picker_helper.dart` numbers (Q4): `ImageUploadRules.pickMaxDimension = 1600` and `pickJpegQuality = 85`, private constants for the native crop screen. Not `Dimensions`: they are output pixels and quality, and screen scaling would change the saved image size per phone.
- **Owner decisions:**
  - **Q1:** the withdraw button follows only `can_request_withdraw` / `withdraw_block`; the `availableBalance <= 0` check and its toast are gone. In the sheet, an amount above the shown balance shows `wallet_withdraw_exceeds` as a live hint (not an error) and never blocks; the server answers `withdraw_insufficient_balance` / `withdraw_no_balance` (mapped in D-08). No new translation key.
  - **Q2:** Edit Profile shows the phone read-only. The phone is out of the "nothing changed" check, the validation (`validateProfileForm` takes an optional `phone`; null skips the phone rules) and the model sent.
  - **Q3:** the iOS proof picker stays gallery-only (note below).
  - **Q6:** `stash@{0}` was re-checked hunk by hunk: all 37 added lines and every removal are already in HEAD (f2d42ac). Dropped; commit 58affccc8321eeeb064649f893fd991c82e46542 can be restored with `git stash store`.
- **Tests:** 14 new, 365 total, 365 passed, 0 failed. Analyze: 0 issues.
  - Files: `get_di_test` 2, `withdraw_hint_test` 5, `profile_phone_readonly_test` 3, `bottom_nav_overflow_<size>_test` 4 (one file per size, see code-traps).
  - **Fail on the old code by behaviour** (a temporary `git worktree` at `development` 4c109ba, removed afterwards; the profile file ran without P3, which does not compile there):

    | Test | Old-code result |
    |---|---|
    | T1 | all 11 concrete services registered: `[HtmlService, WalletService, ForgotPasswordService, ChatService, LanguageService, SplashService, NotificationService, ProfileService, AddressService, AuthService, OrderService]` instead of empty |
    | Q1a | 0 `WalletWithdrawSheet` (the no-balance toast instead) |
    | Q1c | 0 widgets with text `wallet_withdraw_exceeds` while typing |
    | Q1d | 0 widgets with text `wallet_withdraw_confirm_title` (blocked by the old check) |
    | P1 | `readOnly` false |
    | P2 | 0 update requests instead of 1 (the empty phone failed validation) |

  - **Fail on the old code at compile time only:** P3 (optional `phone`), G2 x4 (no `DashboardBottomNavWidget`).
  - **Guards** (pass on the old code): G1 (every interface resolves, languages load), Q1b (a server block opens no sheet), Q1e (no hint within the balance).
  - G2 renders with the test font, so it checks the layout arithmetic only; the real nav check stays on a device (D-11).
  - **Covered by compile, analyze and the full suite only:** rows 40, 56, 57, 58, the duplicate widget, `camera`, `orderIndex`.
- **Device:** **not run.** The steps are in `docs/device-test-backlog.md` (D-10, steps 1–8) and run in D-11.

### Notes (found during D-10, not fixed)
- Edit Profile: the avatar badge sits in two nested `PositionedDirectional` (`update_profile_screen.dart`), which reports "Incorrect use of ParentDataWidget" in debug. The D-10 profile tests ignore that one report.
- The phone prefix in `CustomTextFieldWidget._buildPrefix` uses raw sizes (95, 85, 50, 25, 20, 2) and a fixed `+970`; with a wide font it overflows its 85 px box. Tests ignore that overflow too.
- The bottom nav children (`bottom_nav_item_widget.dart`: 56x30 pill, paddings 16/14/6/4/2, fonts 9/9.5/10.5, `Get.width < 360` branch; `bottom_nav_road_indicator.dart`: 45x8, 7, 11/6/3) keep raw sizes.
- The dashboard "press back again to exit" still uses `ScaffoldMessenger.showSnackBar` (not migrated: no row covers it).
- `wallet_withdraw_no_balance` is no longer used by the app (kept in en/ar).
- The order proof picker keeps its own `imageQuality: 70, maxWidth: 1600` (`order_controller.dart`), separate from `ImageUploadRules.pickJpegQuality` (Q4: unchanged on purpose).
- iOS proof picker: still gallery only (Q3, left as is).
- `RECORD_AUDIO` is declared in the app manifest with no audio feature in the app.
- D-07 note "a cold start from a push skips `updateToken()`" is behaviour, not cleanup: review in D-11.

## Open backend questions

<!-- The only place new backend questions are recorded. Move a row to docs/backend-changes.md once the owner agrees. -->

| ID | Endpoint | Question / needed change | Why | Raised in | Status |
|---|---|---|---|---|---|
| B-01 | /api/v1/delivery-man/* (current-orders, latest-orders, all-orders, order, order-details, profile, remove-account, earning-report, message/*) | Can these accept the Bearer header only, so the app stops sending `?token=` in URLs and `token` in bodies? | Tokens in URLs end up in server, proxy and CDN logs (audit row 9) | D-00 | resolved in D-02: Bearer only (backend docs Doghri-App-Screens, rider R1-R7, 2026-10-14: the token query or body field is only a fallback). The only exception is the WebSocket location body, while `websocket_status` is 0 |
| B-02 | /api/v1/delivery-man/update-order-status | When `dm_picture_upload_status` is on, is a delivery photo mandatory? Does the server reject `delivered` without `order_proof`? | The app shows the photo section but never requires it (audit row 49) | D-00 | answered (same docs): `order_proof` is optional on the server (array, max 5, stored only with `delivered`). Owner decision for D-09: the photo is optional and never blocks a delivery. Done on the app side in D-09 |
| B-03 | /api/v1/delivery-man/wallet/withdrawals | Does the response include a total count for paging past `limit=20`? | Older withdrawals are never shown (audit row 42) | D-00 | answered (same docs): returns `total_size`; `limit` 1-50; `offset` is a page number starting at 1 |
| B-04 | /deliveryman-earning-report-invoice/{id} | What Content-Type and charset does the PDF response use? Full question list in docs/backend-changes.md (B-04 questions) | The app saved decoded text as bytes, so a utf-8 charset corrupted the file (audit row 41) | D-00 | open. Since D-08 the app writes the raw bytes and checks the `%PDF-` signature, so the charset no longer matters to the app. Route, auth and parameters are still unverified. D-09 added upload-limit questions 7–11 (nginx and PHP limits, profile image rules, `order_proof` limits) to the same list |
| B-05 | /api/v1/delivery-man/record-location-data | The screens file describes this as the ticker that runs while the rider is carrying an order, and it reads `order_id`. The app posts every 10 s whenever the rider is online and sends no `order_id`. Does the backend want location only while carrying an order, and with the `order_id`? | Rows with no order may be stored as junk history (follow-up of audit row 38). Question only: no app change in D-06 | D-06 | open |
