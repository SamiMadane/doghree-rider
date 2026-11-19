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

## Template

### METHOD /path

- Auth:
- Request (query / body / multipart):
- Response 200 shape:
- Error codes and bodies:
- Used in:
- Notes:
