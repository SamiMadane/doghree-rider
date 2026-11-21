# API contract

Endpoints as the rider app actually uses them. Fill one section per endpoint when a batch touches it.

## Endpoints

### POST /api/v1/auth/delivery-man/login

- Auth: public.
- Request (body): `phone`, `password` (min 6). Any spelling of the number works, because the server normalises it.
- Response 200 shape: `{ "token": "<120-char random>", "topic": "...", "zone_topic": "..." }`.
  - `topic` is `delivery_man_<zoneId>_<vehicleId>`. A store rider gets `restaurant_dm_<store_id>`. A rider with no zone gets the literal `No_topic_found`.
  - `zone_topic` is `<zone deliveryman_wise_topic>_push`, or `''` for a store rider.
- Error codes and bodies:
  - 403 validation (`code` = `phone` / `password`)
  - 401 `auth-001` wrong credentials
  - 401 `auth-003` not approved **or** suspended (same code, different message: show the message, do not branch on the code)
  - 429 `too_many_requests` (10/min per number)
- Used in: `AuthRepository.login`, then `AuthController.login`.
- Notes:
  - The app saves topics as null-safe (`''` → removed) and never subscribes `''` or `No_topic_found`.
  - A new login invalidates the previous token.
  - There is no logout endpoint.
  - Source: docs/backend R1.

### PUT /api/v1/delivery-man/update-fcm-token

- Auth: Bearer header.
- Request (body): `{ "_method": "put", "fcm_token": "<device token>" }`. `fcm_token` is **required**.
- Response 200 shape: `{ "message": "successfully updated!" }` (translated for the rider).
- Error codes and bodies: a call without `fcm_token` fails validation.
- Used in: `AuthRepository.updateToken`: after login, at splash or app start, on a language change, and when notifications are turned on. It is silent (`handleError: false`).
- Notes:
  - Never sent without a token. Before D-03, logout and notifications-off sent it without `fcm_token`, so it always failed.
  - Since D-03 the device is released with FCM `deleteToken` instead.
  - Not sent while the notification setting is off.

### PUT /api/v1/delivery-man/accept-order

- Auth: Bearer header.
- Request (body): `{ "_method": "put", "order_id": <id> }`.
- Response 200 shape: `{ "message": "Order accepted successfully" }` (translated). The app never needs the body; a non-Map 200 body is accepted.
- Error codes (status and `errors[0].code`; the app never reads the text to decide):
  - 403 `order_id`: validation. The card is kept.
  - 404 `order`: not in the claimable pool (taken, wrong zone or status, refused before). The card is removed.
  - 404 `active_status`: the rider is offline. The app prompts the online toggle and shows no toast.
  - 405 `dm_maximum_order_exceed`, `vehicle_out_of_range`, `store_transfer`, `deposit_required`, `trust_ramp_limit`, `deposit_cover_exceeded` (two different texts), `dm_maximum_hand_in_cash`: the card is kept and the server message is shown once.
  - 409 `order_already_taken`: lost the race at the write. The card is removed.
- Used in: `OrderRepository.acceptOrder` (`classifyAccept`), then `OrderController.acceptOrder`, then `acceptFromCard` (order widgets).
- Notes: a confirmed parcel jumps to `handover` on accept. Source: docs/backend R3 step 2.

### PUT /api/v1/delivery-man/update-order-status

- Auth: Bearer header. Sent as multipart POST with `_method=put`.
- Request (fields): `order_id`, `status` (not `order_status`), `otp` (empty unless delivered, or a parcel pickup), `reason` (cancel only), `order_proof[]` (up to 5 images).
- `order_proof[]` is stored only with `delivered`. The app attaches photos only to `delivered` of the order they were picked for.
- Rider transition map (`riderMayMoveTo`): `picked_up` from accepted, confirmed, processing or handover. `delivered` from picked_up only. `handover` from pending, accepted, confirmed or processing, parcels only. `canceled` from pending, accepted or confirmed.
- Response 200 shape: `{ "message": "Status updated" }` (English literal).
- Error codes:
  - 403 `invalid_status_transition` (English text) and 403 `not_found`: the order changed. The app shows its own text, then refreshes the running orders and the open order.
  - 404 `order`: treated the same as the order having changed.
  - 403 `status`, `order-confirmation-model`, `delivery-man`: shown as a plain failure.
  - 406 `otp`: wrong OTP (only when delivery verification is on). The app shows its own text.
  - 406 `error`: delivered failed while writing the wallet transaction. The order is **not** delivered. The app shows the server message and the rider can retry.
- Used in: `OrderRepository.updateOrderStatus` (`classifyStatus`), then `OrderController.updateOrderStatus`.
- Source: docs/backend R4 step 1.
- **Proof photos (D-09, owner decision B-02: optional).** The server rule is `order_proof => 'array|max:5'`: no required, mime or size rule. Photos and the status travel in **one** request; there is no separate photo endpoint, and `delivered` is refused from anything but `picked_up`, so photos can never be uploaded later.
  - Before sending `delivered`, photos that can no longer be read are dropped (`ImageUploadRules`). The rest go as `order_proof[]`, each labelled by its real content type.
  - A `delivered` request **with photos** that ends in 413, 403 with an `errors[].code` of `order_id` or `status`, 5xx, statusCode 0 or 1 is never resent automatically. One silent `GET order` decides (`classifyProofFailure`):
    - `delivered`: success. `order_proof_full_url` (read with `hasProofImages`) picks `order_delivered` or `delivered_photos_not_saved`.
    - `picked_up` after 413 or the 403 field code: the rider is asked to deliver without photos. Yes sends the same body once with no files.
    - `picked_up` after 5xx: `order_not_delivered_retry`. After 0 or 1: `delivery_unconfirmed` (the request may still finish).
    - not found: the D-04 order-changed path. Fetch failed: `delivery_unconfirmed`.
  - **Not documented:** what the server answers when PHP drops an oversize body. The 403 `order_id`/`status` case follows the documented validation envelope (Screens, error shape 1). The lost `_method=put` could also give 405, or Laravel `ValidatePostSize` a 413; 405 is not treated as a photo failure (B-04 questions 7–11).

### GET /api/v1/delivery-man/order?order_id=<id>

- Auth: Bearer header. Scoped to this rider.
- Response 200 shape: a single order object (Map).
- Not found: 404. Older docs said 204; the app treats 204 as not found too.
- Used in: `OrderRepository.get` (`handleError: false`, `classifyFetch`), then `OrderController.getOrderWithId`. Polled every 10 s by Order Details. A failed poll is silent. Not found closes Order Details with one message.
- Source: docs/backend R4 step 4.

### GET /api/v1/delivery-man/order-details?order_id=<id>

- Auth: Bearer header.
- Response 200 shape: a normal order gives the details array, a parcel gives the order object, a prescription order gives `[]`. The app parses only a List and treats anything else as no lines.
- Error codes: 403 validation, 404 `order`.
- Used in: `OrderRepository.getOrderDetails` (`handleError: false`), then `OrderController.getOrderDetails`, which shows exactly one message on failure. Parcels are not fetched.
- Source: docs/backend R3 step 1.

### GET /api/v1/delivery-man/all-orders?limit=10&offset=<page>

- Auth: Bearer header.
- Request (query): `limit` (the app sends 10) and `offset`, a **page number starting at 1**.
- Response 200 shape: `{ "total_size": <server count>, "limit": "10", "offset": "1", "orders": [ ... ] }`. `limit` and `offset` may be strings. The app also accepts a string `total_size`.
- **Not in Screens R1-R7.** The shape comes from the Postman example only. Its example nests a `store` object, but Screens R2 and the app use flat `store_*` keys.
- Used in: `OrderRepository.getCompletedOrderList` (always `handleError: false`, a 401 still ends the session), then `OrderController` (`getCompletedOrders(1)` and `loadNextHistoryPage`).
- Notes:
  - A body that is not a Map is a failure (null). A missing `orders` list ends the history.
  - `total_size` counts server rows. The app drops orders without items, so the list on the phone is shorter. More pages exist while `lastLoadedPage * 10 < total_size` and no page came back empty.
  - The same order id can appear on two pages if orders move meanwhile. The app shows it once.

### GET /api/v1/delivery-man/latest-orders, current-orders and notifications

- Auth: Bearer header. No parameters, no pagination.
- Response 200 shape: a **bare JSON array** (R2 steps 1, 2, 6). `[]` is a real empty list. latest-orders is `200 []` when the deposit guard hides the board. notifications is `200 []` on any server exception, so an empty list does not prove there are none, and it keeps only the last 15 days.
- Order fields: `store_lat` and `store_lng` arrive as strings. For an order with no store, every `store_*` key is explicitly null.
- Used in: `OrderRepository.getLatestOrders` (silent), `OrderRepository.getList` (current), `NotificationRepository.getList`.
- Notes: a 200 whose body is not a List is a failure (null) and the old list stays. A single item that does not parse is skipped (`JsonHelper.mapList`).

### FCM push data (rider)

- Documented types (API guide v3, Screens R2 and R6): `new_order`, `order_status`, `order_request`, `message`, `withdraw`. The app also handles `assign`, `unassign`, `block`, `unblock`, `otp` and `cash_collect`, which come from older server code. They are not in the docs.
- `order_id` and `conversation_id` arrive as strings. The withdraw push sends `order_id: ''`. The app reads ids with `NotificationRouter.validId`, so a missing, empty or non-numeric id is null.
- Decisions use `type` (and `body_loc_key`/`title_loc_key` on the dashboard listener) only, never the text.
- A request push can be for an order this rider cannot carry. The app opens or refreshes the Requests board and never deep-links the pushed order (R2).
- Withdraw delivery is best-effort. The app refreshes `GET /wallet` and withdrawals instead of trusting the push (R6).
- Used in: `NotificationHelper.convertNotification`, `NotificationRouter`, `ForegroundOrderPush` (dashboard).

### GET /api/v1/delivery-man/message/details

- Auth: Bearer header.
- Request (query): `conversation_id`, or `user_id` / `vendor_id`, plus `offset` and `limit` (10).
- Response 200 shape: a Map with `total_size`, `limit`, `offset`, `conversation` and `messages` (a list).
- **Not in Screens R1-R7.** Postman has the request only, with no saved response, so the shape comes from the app's model.
- Used in: `ChatRepository.getMessages`, then `ChatController.getMessages`.
- Notes:
  - A 200 body that is not a Map (for example `[]`) is a failure (null).
  - A missing, null or wrong `messages` field is an empty list. An empty list still gives a model, so a new conversation opens.
  - The numbers are read with `JsonHelper.asInt` (D-07, row 54).

### PUT /api/v1/delivery-man/update-profile

- **Not in Screens R1-R7.** The request comes from Postman (request example and one saved 200); nothing was observed on a device yet.
- Auth: Bearer header. Sent as multipart POST with `_method=put`, 60 s timeout, `handleError: false` plus `checkSession`.
- Request (fields): `f_name`, `l_name`, `email` (each only when the app has a value), `image` (only when a photo was picked; jpeg, png or webp up to 2 MB on the app side). Postman also lists `password` with `current_password` and `vehicle_id`, which the app does not send. The phone shown on the screen is never sent.
- Response 200 shape: `{ "message": "successfully updated!" }`.
- Errors: 403 with a field `code` (for example `email`, `current_password`). The app shows the server text once. 401: the session sheet only.
- **Unknown:** the server rules for `image` (mimes, maximum size). See B-04 questions 7–11.
- Used in: `ProfileRepository.updateProfile`, then `ProfileController.updateUserInfo`.

### GET /api/v1/delivery-man/wallet

- Auth: Bearer header. No parameters.
- Response 200 shape: a Map with `available_balance`, `total_earning`, `total_withdrawn`, `pending_withdraw`, `cash_in_hand`, `rider_share_percent`, `withdraw_min_amount`, `week_start`, `week_end`, `timezone`, `can_request_withdraw`, `withdraw_block` (`{code, message}` or null), `next_withdraw_from`, `this_week_request`, `accounts[]` and `methods[]` (Screens R5).
- Money: JSON numbers rounded to 2 decimals. The app shows them as sent and never recomputes a balance or a share. Do not apply `digit_after_decimal_point`.
- The screen follows `can_request_withdraw` and `withdraw_block` (`withdraw_block.code` is only `withdraw_weekly_limit`, `withdraw_no_balance` or `withdraw_minimum`).
- Used in: `WalletRepository.getWallet` (silent: `handleError: false` plus `checkSession`), then `WalletController.getWallet`. Called on Home, on the Wallet screen, after a delivery, on a withdraw push and after wallet actions. A failure keeps the last known wallet (D-08, row 43).

### POST /api/v1/delivery-man/wallet/withdraw

- Auth: Bearer header.
- Request (body): `amount` (required, numeric, 0.01–1000000), `account_id`, `withdrawal_method_id`, `fields`, `note` (max 255). The app sends `amount`, `account_id` (the default account) and a trimmed `note`.
- Response 200 shape: `{ message, withdraw: {...}, wallet: {...} }` (R6).
- Error codes: 403 with two families. The service returns the first match:
  - field-name codes: `amount`, `fields`, `withdrawal_method_id`, `note`
  - domain codes, in this order: `withdraw_weekly_limit`, `withdraw_no_balance`, `withdraw_amount`, `withdraw_minimum`, `withdraw_insufficient_balance`
  - `withdraw` for any account or method problem
  - `rider_withdraw_account_required` when there is no saved account (R6 text)
- Used in: `WalletRepository.requestWithdraw` (`classifyWithdraw`), then `WalletController.requestWithdraw`.
  - The decision uses the status and the first recognized `errors[].code` in list order, never the text.
  - The rider sees one inline message (the server text, or a local key).
  - The silent refreshes follow the outcome (see progress.md D-08).
- Notes:
  - Key off `payout_method` and `withdrawal_method_id`, never off a `*_label` or `method`.
  - One request per Saturday-to-Friday week (Asia/Gaza). A rejected request frees the week.

### GET /api/v1/delivery-man/wallet/withdrawals?limit=20&offset=<page>

- Auth: Bearer header.
- Request (query): `limit` (no validator; clamps to 1–50, default 20) and `offset`, a **page number from 1**.
- Response 200 shape: `{ "total_size": N, "limit": 20, "offset": 1, "withdrawals": [ ... ] }`, newest first. Each row has `id`, `amount`, `status` (`pending | paid | rejected`), `status_label`, `requested_at` (ISO 8601), `method`, `account`, `note`, `payout_*`, `paid_at`, `rejection_reason`, `admin_note`.
- Used in: `WalletRepository.getWithdrawals(page)` (silent, `query:` map, `WithdrawalsPage.fromBody`), then `WalletController.getWithdrawals` (page 1) and `loadNextWithdrawalsPage`.
- Notes:
  - A body that is not a Map, or `withdrawals` that is not a List, is a failure (null). Bad rows are skipped.
  - More pages exist while `page*20 < total_size` and no page came back empty. A missing `total_size` ends the paging.
  - The same id can appear on two pages after a new request. The app shows it once.

### DELETE /api/v1/delivery-man/wallet/accounts/{id}

- Auth: Bearer header.
- Response 200 shape: `{ "message": "..." }`.
- Error codes: 404 `{ "errors": [ { "code": "account", ... } ] }` when the account is not found.
- Used in: `WalletRepository.deleteWalletAccount` (`classifyDeleteAccount`, silent), then `WalletController.deleteWalletAccount`, which shows one message and refreshes the wallet on 200 or 404.

### GET /deliveryman-earning-report-invoice/{deliveryman_id}

- **Not in any backend file** (Screens, API guide v3, Postman). B-04 is open; see the questions in docs/backend-changes.md.
- Auth: the app sends the Bearer header. Whether the route accepts it is unverified.
- Request (query): `type` (`all`, `delivery_fee`, `delivery_tips`), and `start_date` and `end_date` only as a pair.
- Response: expected `application/pdf`. The real Content-Type and charset are unverified.
- Used in: `WalletRepository.downloadEarningInvoice` → `ApiClient.getBytes` (raw `bodyBytes`, silent, 60 s timeout, logs the byte length only), then `WalletController.downloadEarningInvoice`. The file is written only when it starts with `%PDF-`.
- Error bodies are decoded leniently (UTF-8, malformed bytes allowed) for the server message.

### Retired: store-transfer delivery fees

- `GET /api/v1/delivery-man/store-transfer/delivery-fees` and `PUT .../store-transfer/delivery-fee-received` answer **410** `{ deprecated: true, replacement: "/api/v1/delivery-man/wallet", errors: [{ code: "endpoint_removed" }] }` (R5). The app calls neither of them. Never retry on a 410.

## Template

### METHOD /path

- Auth:
- Request (query / body / multipart):
- Response 200 shape:
- Error codes and bodies:
- Used in:
- Notes:
