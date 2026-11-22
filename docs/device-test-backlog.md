# Device test backlog

All device steps run together in D-11, after D-10. No device result is recorded as passed until it has been run on a phone.

## D-01: start-up and session

- **Branch:** fix/d-01-startup
- **Merge commit:** f46460d
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Logged in, with internet, cold-start the app | Splash, then the dashboard. No toast |
| 2 | Force-stop, airplane mode on, cold start, then airplane mode off and tap Retry | The compact no-connection screen shows. Retry reaches the dashboard. Exactly one message; no toast and no 6000 s bar |
| 3 | Logged in, very bad network (or a server error), cold start | The no-connection screen with Retry, not sign-in. The session is kept |
| 4 | Uninstall, reinstall, first launch | The language screen, then sign-in. Language and notification defaults are set on the first launch |

**Unit tests only:** fresh-install defaults all set in one call (T1), config `handleError: false` (T3), session status mapping for 401, offline, 403, 5xx and parse errors (T4–T8), and the single-load and single-navigation guard (T9–T11).

## D-02: silent network, Bearer-only auth, log privacy, URL encoding

- **Branch:** fix/d-02-silent-network
- **Branch commit:** 270146c
- **Merge commit:** the `--no-ff` merge of fix/d-02-silent-network into development (265bcfa)
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Log in, go online, open Requests, airplane mode on for 30 s, then off | No toasts while offline. The requests reload by themselves afterwards |
| 2 | Airplane mode on, open My Orders, tap Retry, then airplane mode off and tap Retry | The no-connection screen shows. The first Retry shows one "still no internet" toast. The second Retry loads the list |
| 3 | Chat: search `a&b`, then `+` | No error. The results match a name containing the text, or the list is empty |
| 4 | Log out, then Forgot password with a phone in `+` format, enter the code | The verification screen shows the full number. The new-password screen opens and the reset succeeds |
| 5 | Run in debug for one minute (orders, profile, chat, forgot password), then search the console for `token=`, the phone digits and `lat=` | No matches |
| 6 | Force-stop, airplane mode on, cold start, then airplane mode off and tap Retry | The splash no-connection screen shows. Retry reaches the dashboard (NoInternetScreen still works after the `onRetry` change) |

**Unit tests only:** the full list of requests without a token (T3a–T3d, including endpoints the smoke pass does not reach), a reset code containing `+`, `&` or `=` (T10a), and log redaction of GetX route strings (T1). The FCM-token body change on login and logout has no unit test (FirebaseMessaging is static) and is exercised by the smoke login and logout.

## D-03: login, logout, FCM release, remember-me, block, delete account

- **Branch:** fix/d-03-auth
- **Branch commits:** 6135f36 (main fix), 6f10228 (no token while notifications are off)
- **Merge commit:** the `--no-ff` merge of fix/d-03-auth into development (see `git log`)
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Language Arabic. Log out, then log in with a wrong password | Sign-in shows the error in Arabic |
| 2 | Log in with remember-me ticked, then log out | The phone is prefilled, the password is empty. The OS password manager offers the password |
| 3 | Log out, then trigger an order push to this rider (user app or admin) | No push arrives on the logged-out device |
| 4 | Log in again, then trigger a new order | The push arrives |
| 5 | Admin blocks the rider while the app is open | Sign-in screen. After unblocking, logging in works and pushes arrive |
| 6 | Settings, delete account, airplane mode on, confirm | One error toast. The sheet closes and Settings stays open |
| 7 | Settings: notifications off, then trigger an order push | None arrives |
| 8 | Notifications on, then trigger again | It arrives |
| 9 | Airplane mode on, log out, airplane mode off, restart the app, trigger an order push | None arrives |
| 10 | Notifications off, restart the app, trigger an order push. Then turn notifications on and trigger again | None arrives after the restart. After toggling on, it arrives |

**Unit tests only:** login with a null zone topic or `No_topic_found` (T1, T8), an FCM token failure during login (T2, T8b), an exception during login (T3), the half-saved token rollback (T4), the cleanup order and the 5 s offline bound (T7, T7b), the pending flag and its retry before the next getToken (T12–T14), the delete-account exception and double tap (T9, T10), and no token registration on the splash path while notifications are off (T16).

## D-04: order actions (accept, status change, polling, proof photos)

- **Branch:** fix/d-04-order-actions
- **Branch commit:** see `git log` on fix/d-04-order-actions (code commit "D-04: order actions")
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Two riders online with the same request open. Rider A accepts, then rider B accepts | B: one "no longer available" message and the card disappears. A: Order Details opens |
| 2 | Turn the rider offline on the server side (admin), keep the request list open, accept a request | One "you must be online" dialog. The card stays |
| 3 | Rider at the maximum number of orders, accept another request | The server message, once. The card stays |
| 4 | Order Details open, airplane mode on for 30 s, then off | The screen stays and shows no toast. The status refreshes afterwards |
| 5 | Admin cancels or reassigns the order while Order Details is open | One message, and the screen closes. The running orders list is updated |
| 6 | Take a proof photo on order A, go back, open order B and mark it picked up | Order B's pickup carries no photo. After delivering B, the admin panel shows only B's own photos |
| 7 | Deliver an order with a proof photo | One success message. The photo is on the order in the admin panel |

**Unit tests only:** 406 `error` and 406 `otp` (delivery verification is off live), 409 against 404 `order`, every 405 code except max orders, 204 on GET order, a 200 non-Map body, the exception paths, the double tap on accept and status, the stale-status re-check (T19), the lost delivered response followed by a 403 (T18), and the proof photos kept on reopening the same order (T20).

## D-05: order history paging, getModule, list and model parsing

- **Branch:** fix/d-05-order-lists-parsing
- **Branch commit:** see `git log` on fix/d-05-order-lists-parsing (code commit "D-05: order lists and parsing")
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | My Orders with more than 10 past orders: scroll to the end | Older orders load, none appears twice, and the bottom spinner stops at the end of the history |
| 2 | Scroll to the end with airplane mode on, then turn it off and tap Retry | No toast. The footer shows "Couldn't load more orders" with Retry. Retry adds the page once |
| 3 | After scrolling a few pages, pull to refresh | The list restarts from the newest orders with no duplicates |
| 4 | Cold start, then open Requests, Running orders, Notifications, a chat with an image, and the profile | Everything loads normally. No red screen, no no-connection screen |
| 5 | Open Order Details of a store order and of a parcel | Items, attachments and the map show as before |

Also run the combined smoke pass (this batch touches orders and start-up). While running orders: if a running order is missing from the list, check the debug log for a "skipped" line from `current-orders` (a skipped item hides an order).

**Unit tests only:** a null or unknown `module_type` (S1–S3, W1), wrong body shapes and bad list items (R1–R8), null string lists and a bad config (M1–M4), a string `total_size` (M5), a missing `orders` list (M7, P2), the stale page after a refresh (P6), one request in flight (P11), the end-of-history rules (P7, P8), no auto-load after a failure (P9) and the auto-fill rule (P10).

## D-06: order ringing, notification title, location recording

- **Branch:** fix/d-06-location-ringing
- **Branch commit:** see `git log` on fix/d-06-location-ringing (code commit "D-06: location and ringing")
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Online, app in the background (home screen). Trigger a new order push, wait for the ringing, open the app from the launcher | The ringing stops at once |
| 2 | Same, but tap the ringing notification | The app opens and the ringing stops |
| 3 | Same, then accept the request | No ringing after the accept |
| 4 | Same, then ignore the request | No ringing after the ignore |
| 5 | Push, let rider B take the order, then open the app on rider A | The ringing is already stopped on open. The card is gone after the refresh |
| 6 | Push, do not touch the phone | The ringing stops by itself after about 60 s |
| 7 | Push to the background app. On Android 14 or newer, swipe the ringing notification away | The ringing stops |
| 8 | Push, then log out (or block the rider from the admin panel) | No ringing on the sign-in screen |
| 9 | Assign push with no `order_id` (admin test payload) | The title has no "(null)" |
| 10 | Android settings, app notifications, after updating over an old build | No "Foreground Service Notification" (stackfood) channel. The server notification channel is still listed |
| 11 | Online with GPS off for 60 s, then GPS on | No crash, no toast. No new location rows in the admin panel while off, rows again within about 20 s |
| 12 | Online, revoke location permission in Settings, wait 30 s, grant it, return | Same as step 11 |

**Device only (unit tests prove the decisions, not Android):** the service really stopping and the sound ending (steps 1–8), the real title (9), the channel list (10), real GPS and permission changes (11, 12).

**Unit tests only:** the cap rule (R11), the title text (R8–R10), the channel guard (R12, R13), every stop call site (R4–R7), a throwing position read, no position, no config, overlapping ticks and recovery (L1–L6), the usable-fix rules (L7), and the whole WebSocket path (W1–W4, off live).

## D-07: push taps, push ids, chat push, message parsing

- **Branch:** fix/d-07-notifications
- **Branch commit:** see `git log` on fix/d-07-notifications (code commit "D-07: notifications")
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | App killed. Admin pays or rejects a withdrawal. Tap the push | The wallet opens with the new state. Back goes to the dashboard |
| 2 | App killed. The store confirms an order this rider accepted (order_status push). Tap it | Order Details of that order. Back goes to the dashboard, not a blank splash |
| 3 | App in the background, a new order push. Tap it | The Requests tab with a fresh list. Back goes to Home, and a double back exits (only one dashboard) |
| 4 | App in the foreground on Home, a new order arrives | The request sheet shows once |
| 5 | Foreground on the chat list, the customer sends a message. Tap the notification | A notification shows. The tap opens that chat |
| 6 | Inside that chat, the customer sends another message | The message appears in place. No notification |
| 7 | Log out, then tap an old push still in the tray | Sign-in. No crash |
| 8 | App killed, admin unblocks the rider (logged in). Tap the push | The app opens on the dashboard, not sign-in |

**Device only:** the cold-start wiring opening the target exactly once with the dashboard underneath (1, 2, 8; the decision itself is unit-tested by C1 and C2), the real stack depth (3), and the real FCM payloads.

**Unit tests only:** pushes without or with a non-numeric `order_id` or `conversation_id` (N1–N4b, N8, N10, R3, R6), a chat push while the chat is still loading (N9; the timing cannot be forced on a device), a message body that is not a Map or has a bad `messages` field (N5–N7), the full type table including block and unblock (R1–R14), and the base64 round trip with a `+` (G2, G3).

## D-08: wallet (invoice PDF, withdrawals paging, withdraw messages, account delete)

- **Branch:** fix/d-08-wallet
- **Branch commit:** cd20147
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Earnings → Download, with no filter, then with a type and a date filter | A PDF opens in a viewer each time. The download spinner stops |
| 2 | Airplane mode on → Download | One message. The spinner stops |
| 3 | A rider with more than 20 withdrawal requests → Wallet → See all, scroll to the end | Older requests load. No row appears twice. Newest first |
| 4 | Step 3, airplane mode on before scrolling to the end, then off and tap Retry | The footer shows "Couldn't load more withdrawal requests" with Retry. Retry continues. No toast |
| 5 | Pull to refresh on the list after step 3 | The list starts again from the newest page |
| 6 | Airplane mode on → Request withdrawal → submit | One inline message under the form. No toast. The sheet stays open |
| 7 | Request a withdrawal this week, then open the Wallet again | The button is grey and the server notice shows (withdraw_block). If the sheet is still reachable, a second request shows the server weekly-limit text inline and the wallet refreshes |
| 8 | Delete the payout account, tapping Delete twice fast | One delete, one toast. The wallet screen stays open |
| 9 | Airplane mode on, open Home and the Wallet | No toasts from the wallet or the withdrawals. The last known balance stays |

**Device only:** the PDF really opening, the real Content-Type and charset of the invoice route and whether it accepts the Bearer header (B-04, steps 1 and 2); the real withdraw rules from the server state (weekly limit, minimum, no balance; step 7); the confirm sheet ignoring a second tap (step 8). The smoke pass applies (orders and money).

**Unit tests only:** every withdraw error code, several codes in one `errors[]`, 401 and 410 for withdraw and delete (C-*, W1–W7, D1–D6); a PDF with a utf-8 charset byte for byte (B1); a 200 that is not a PDF (B2); a late page after a refresh, duplicate ids, an empty page, a missing `total_size` (P3–P9); keeping the last known values after a failed refresh (K1, K2).

## D-09: uploads and profile (photo checks, profile save, optional delivery proof)

- **Branch:** fix/d-09-uploads-profile
- **Branch commit:** 226aba3
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Edit profile → change the photo (camera) → Save | One success message. The new photo shows. The spinner stops |
| 2 | Edit profile → pick a gallery photo over 2 MB (a large panorama, if the crop keeps it big) | One "too large" message. The old photo stays |
| 3 | Turn camera permission off in phone settings → Edit profile → camera. Then Order Details (picked up, photo section on) → add photo → camera | One permission message each time. No crash |
| 4 | iPhone: add a HEIC proof photo from the gallery | Accepted (image_picker re-encodes it as JPEG) or refused with "format not supported". Never stored as a broken file in the admin panel |
| 5 | With `dm_picture_upload_status` on, deliver an order with no photo | The photo section says it is optional. Delivered. One message |
| 6 | Deliver an order with 2 proof photos | One message. Both photos are on the order in the admin panel |
| 7 | Add a proof photo, turn airplane mode on, swipe deliver, turn airplane mode off within about 5 s | One message: delivered, delivered but photos not saved, or not confirmed yet. The admin panel shows one delivery only. Order Details shows the real status within 10 s |
| 8 | Double-tap Save on Edit profile | One request, one message |

**Device only:** the real HEIC behaviour of image_picker (step 4); permission prompts (step 3); the content type the server stores (steps 4 and 6). The smoke pass applies (orders and money).

**Unit tests only:** 413 and the dropped-body 403 with the deliver-without-photos confirm, Yes and No, identical resend fields, a double Yes (D2, D2b, D2c, D2d, D10); a proof file gone from the cache (D1, D9); 5xx, statusCode 0 and 1 with the order still picked up, and a failed check (D5–D8); `order_proof_full_url` shapes (J1–J6); the null email and the profile save exception and double tap (R1, U1–U6); content-type labelling (M1–M3).

## D-10: cleanup (dead code, DI, stray files, bottom nav sizes, withdraw and phone decisions)

- **Branch:** fix/d-10-cleanup
- **Branch commit:** 346c25a (code), 0723948 (manifest uses-feature)
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Cold start while logged in; open Home, Requests, My Orders, Profile from the bottom nav | Dashboard opens; each tab opens; back from a tab returns to Home |
| 2 | Look at the bottom nav on the smallest and the largest phone available, light and dark theme | Labels readable, no yellow/black stripe, the road indicator sits over the active tab |
| 3 | Registration: pick the profile photo and an ID photo, once from the gallery and once from the camera, with crop; open the zone list | Photos show after crop; the zone list loads |
| 4 | Edit Profile: try to type in the phone field; change the photo (camera) and the name; Save | The phone cannot be edited; one success message; new name and photo show |
| 5 | Edit Profile: change nothing, Save | One "change something to update" message, no request |
| 6 | Wallet with a balance shown and withdrawing allowed: open Request withdraw, type more than the balance, submit | The hint "Amount exceeds your available balance" shows while typing, the confirm dialog still opens, and the server's message decides (one inline message) |
| 7 | Wallet with a zero balance shown but `can_request_withdraw` true | The button is active and opens the sheet; the server answers |
| 8 | Cash order: deliver through the confirm-delivery sheet (OTP, one proof photo from the camera on Android) | Delivered, one message |

**Device only:** real nav sizes and fonts (step 2; G2 uses the test font), camera and crop after the `camera` package removal (steps 3, 4, 8). The smoke pass applies (orders and money).

**Unit tests only:** single DI registration per service (T1, G1); the withdraw decisions with the server flag false (Q1b) and within the balance (Q1e); phone-less profile save (P2, P3).

## D-12: safety net, start-up, failure texts, silent Home loads, crash fixes

- **Branch:** fix/d-12-static-checks
- **Branch commits:** d3667ab, d0f6b52, a745ad4, bc03be4, d72e23e (docs b469a8d); merged into `development` 2026-11-22
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Block the API host on Wi-Fi (or point to a server that answers 500), then cold start | "Server problem" with Retry |
| 2 | Airplane mode on, cold start | "No connection" with Retry; turning the network on loads the app |
| 3 | Turn airplane mode on as soon as the splash animation ends, so the Home first load fails | Exactly one message |
| 4 | Reconnect and pull to refresh on Home | Data shows, no message |
| 5 | Send the app to the background and back while offline, with data on screen | No message |
| 6 | Chat: send a message with airplane mode on | One message; the send button works again |
| 7 | Chat: open a long conversation, scroll up to load older messages, leave the chat while it loads | No crash; the list works when opened again |
| 8 | Forgot password with airplane mode on | One message; the button stops loading |
| 9 | Sign-in screen | The phone prefix shows the same flag and +970 as before; the sizes look unchanged |
| 10 | Home: log out right after opening Home (location permission check running) | No crash; sign-in opens |

**Device only:** steps 7 and 10 (C6, C7) and the real look of the phone prefix (step 9). The smoke pass applies (start-up).

**Unit tests only:** a 200 with an HTML body (chat, forgot password, cancel reasons, splash), a notification without `updated_at`, corrupt stored entries, an unknown or missing country, Firebase not ready, `StartupFailedApp`, and the error handler.

## D-13: Retry states (Conversations, Chat, Notifications, privacy and terms), Firebase OTP message

- **Branch:** fix/d-13-retry-states
- **Branch commits:** 5a1a0cb, 84174c5, 72f3c6c, cfc5896, 8e03b3c (docs 8378447); merged into `development` 2026-11-22
- **Status:** pending (D-11)

| # | Steps | Expected |
|---|---|---|
| 1 | Airplane mode on, Profile, Conversations | "No Connection" with Retry, no toast. Network on, Retry once: the list loads |
| 2 | With the list shown, airplane mode on, pull to refresh | The list stays, no message |
| 3 | More than 10 conversations: scroll down | Older conversations are added below (the list never goes blank) |
| 4 | Airplane mode on, open a chat | "No Connection" in the messages area, the composer below. Network on, Retry: messages load |
| 5 | In a chat, airplane mode on, type a message and send | One message; the typed text stays |
| 6 | Fresh start, airplane mode on as soon as the dashboard shows, open Notifications | "No Connection" with Retry, no toast |
| 7 | Privacy policy and Terms with airplane mode on | "No Connection" with Retry. Online: the page opens (empty state while the admin texts are empty) |
| 8 | Captive Wi-Fi (a hotel or cafe login page), if available, open Privacy policy | "Server problem", never the login page |
| 9 | Forgot password with Firebase OTP: enter a wrong code | One message |
| 10 | Double tap Retry quickly on any failure state | One spinner, one load, no error |

**Device only:** the look of the failure state and the empty page, real scrolling for step 3, the rate-limit timer in step 9.

**Unit tests only:** the 401 path (no failure state), a 200 with raw HTML when no captive Wi-Fi is available, a page that throws during paging, and the busy guard timing.

## D-14: image assets (lossless WebP, resized map markers)

- **Branch:** fix/d-14-assets-size
- **Branch commits:** 386b776 (docs d0eacaf and the closing commit); merged into `development` 2026-11-22
- **Status:** pending (D-11)

Every screen that shows a converted image (17 steps). Each one once in light mode and once in dark mode.

**Highest priority: steps 1 (no_internet) and 16 (session_expired), in light and in dark.** These two keep their pixel size and are shown with no width or height, so their on-screen size comes from the image itself. Run them first. Expected everywhere: the image looks exactly as before (same size, same position, clean edges, no dark or white fringe), and nothing is blank.

| # | Steps | Image(s) |
|---|---|---|
| 1 | **Highest priority.** Airplane mode on, cold start (light, then dark) | no_internet |
| 2 | Home | doghree_coins (earnings card), doghree_parcels (orders card) |
| 3 | Home, go offline (the confirm sheet) | dm_offline_icon |
| 4 | Deny the location permission (the permission dialog) | location_access_icon |
| 5 | Order requests tab with no request; My Orders with no order | no_order |
| 6 | A running order: details while pending, then while processing | order_pending, order_preparing |
| 7 | A parcel order: request card, details card, location cards | store |
| 8 | Order details map preview; open the full map | customer_marker; your_marker, customer_marker, restaurant_marker (store order) or user_marker (parcel) |
| 9 | Order details: the confirm dialog; the slide-to-confirm sheet | warning; confirmation_order |
| 10 | Wallet | balance; empty_account (no payout account) |
| 11 | Earnings: a delivered order row; no earnings; a filter with no result; airplane mode on, open earnings | earning_order; no_transaction (both empty states); earning_error |
| 12 | Settings, Delete account | warning_delete_account |
| 13 | Forgot password, set a new password (success sheet) | change_password |
| 14 | Notifications with none; Conversations with none | no_notification; no_conversation |
| 15 | Privacy policy and Terms (header, and the empty page while the admin texts are empty) | privacy_terms |
| 16 | **Highest priority.** Session expired: log in on a second device, or have the account logged out (light, then dark) | session_expired |
| 17 | Only if the owner can set it: forced update and maintenance mode in the admin panel; a new registration | update, maintenance, application_submitted |

**Device only:** how each image looks (steps 1-17), and the maplibre marker size in step 8 (40 dp wide, as before).

**Unit tests only:** every asset path exists, every raster decodes, each converted file is smaller and has the agreed pixel size, the GIFs keep frames, loop and timing (T1-T4). Step 17 is covered by the contact sheet only unless the owner sets those modes.

The smoke pass applies: step 1 shows a start-up screen, and steps 6-11 show order and earnings screens. No order, money or start-up logic changed.

## D-15: translations (Arabic and English wording, missing keys, location disclosure)

- **Branch:** fix/d-15-translations
- **Branch commits:** 29d1fa8 (and the docs commit); not merged yet
- **Status:** pending (D-11)

Wording only: the screens and behaviour are the same as before.

| # | Steps | Expected |
|---|---|---|
| 1 | Switch to Arabic. Open every main screen: Home, Order requests, My orders, an order's details, Profile, Settings, Wallet, Withdrawals, My earnings, Notifications, Conversations, a chat | New words (for example «متاح / غير متاح», «الزبون», «منتجات», «الإكراميات»), correct RTL layout, no raw key names |
| 2 | Switch to English and repeat step 1 | Sentence case, "Rider", no raw key names |
| 3 | On the smallest phone, in both languages: history status chips, password-rule chips (registration), earnings filter chips, bottom tabs, the order-request sheet title, the go-offline, logout, cancel-order and delete-account dialogs and their buttons | No overflow, no cut text. Longest new chips: «تم الاسترداد», «فشل الطلب», «تم التأكيد», "Ready for handover" |
| 4 | Concatenated keys in context: an order request card (time «5 د» / «3 س» / «2 يوم» and distance «3.25 كم»); order details («3 منتجات», street, house and floor line, add-ons and variations, charge payer on a parcel); profile card days; sign-in «انضم بصفتك مندوب توصيل»; registration terms line and ID label «جواز السفر (الرقم)»; chat list with a deleted user «الزبون (حساب محذوف)»; a withdrawal sheet «إلى حساب: …» | Each sentence reads naturally in the right order, in Arabic and English |
| 5 | Location disclosure: go online with location denied once (sheet A), then denied permanently (sheet B), then on Android "while using the app" only (sheet C). Read each sheet in both languages | The texts say what is collected, while online, even when the app is closed or not in use, and why. Sheet B fits or scrolls on the smallest phone |
| 6 | With the rider online, put the app in the background, then swipe it away; check whether location updates keep arriving (server or admin map) | Write down the result (pre-store item S-3) |
| 7 | Settings → Background notification, in both states. Then on the phone's own battery screen for the app, write down the exact option names | Step 3 says `Select "Optimized"` / `اختر "مُحسَّن"`; compare with the real option name on this phone |
| 8 | Screens of the new keys: forgot password → OTP screen (the «إعادة الإرسال (00:30)» / "Resend (00:30)" button); an invalid number in forgot password; registration with empty and short fields (for example «هذا الحقل مطلوب», «يجب أن تتكون كلمة المرور من 8 أحرف على الأقل»); a payout account name with digits; long-press the earnings button on the Wallet app bar; an order with status refund_request_canceled if the backend can set one | Translated texts, never a raw key |

**Device only:** steps 1-8 (layout, RTL, overflow, the real battery option name, background location after swipe-away).

**Unit tests only:** valid JSON, no BOM, no duplicate keys, same key set and placeholders, no empty values, every static `.tr` key exists, composed-key spacing and word order, glossary, disclosure wording (T1-T8).

The smoke pass applies (orders, money texts changed): accept an order, change its status, deliver with code and photo proof, open earnings.

## Combined smoke pass (once, in D-11)

| # | Step | Expected |
|---|---|---|
| 1 | Accept an order request | The order moves to running orders |
| 2 | Mark it picked up | The status updates. One success message |
| 3 | Mark it delivered with a proof photo | Delivered. The photo uploads |
| 4 | Open earnings | The delivery appears |
| 5 | Open a chat and send a message | The message is sent and shown |
| 6 | Open the profile | The profile loads |
| 7 | Toggle online, then offline | The status changes each time |
| 8 | Change the password in Settings | Success |
| 9 | Log out, then log in with the new password | Logout reaches sign-in. Login reaches the dashboard |

**Status:** pending (D-11)

## D-11: final device pass

Runs after D-10. No release build is made from `development` until it passes.

1. Run every pending section above in batch order (D-01, D-02, D-03, then each later batch) on a real device. The Android emulator may cover the steps that need no camera and no push.
2. Run the combined smoke pass.
3. End-to-end: the user app creates an order. The rider accepts it, picks it up and delivers it with a proof photo. The delivery appears in earnings.
4. If a step fails, record the step, the batch and its commit here, and fix it before the pass is marked done.

**Status:** pending
