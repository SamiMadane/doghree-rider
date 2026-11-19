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
