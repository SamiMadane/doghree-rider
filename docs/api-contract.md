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

## Template

### METHOD /path

- Auth:
- Request (query / body / multipart):
- Response 200 shape:
- Error codes and bodies:
- Used in:
- Notes:
