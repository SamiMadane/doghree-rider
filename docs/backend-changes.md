# Backend changes

Agreed backend changes only. Proposals start in docs/progress.md, Open backend questions.

| ID | Endpoint | Change needed | Reason | Status | App batch |
|---|---|---|---|---|---|

## B-04 questions (open, not agreed)

Added at the user's request in D-08. These are questions only, not an agreed change. The row stays open in docs/progress.md until the owner answers. The earnings statement route is in no backend file (Screens, API guide v3 or Postman).

| # | Question | What the app does today (D-08) |
|---|---|---|
| 1 | **Route:** is `GET /deliveryman-earning-report-invoice/{deliveryman_id}` (outside `/api/v1`) the supported route for the rider statement? Is there, or should there be, an `/api/v1/delivery-man/...` equivalent? Must `{id}` be the logged-in rider's own id, and what answers a foreign id? | Calls the route above with the profile id |
| 2 | **Auth:** does the route accept `Authorization: Bearer <rider token>`? If it does not, what does it answer: 401 JSON, a redirect to an HTML login page, or something else? Is a token in the query required? | Sends the Bearer header only and no token in the query (audit row 9) |
| 3 | **Content-Type and charset:** what Content-Type does a successful response use (`application/pdf`, with or without a charset)? Is it inline or an attachment (Content-Disposition)? | Reads the raw bytes, so any charset is safe. Saves the file only when it starts with `%PDF-` |
| 4 | **Parameters:** are `type` (`all`, `delivery_fee`, `delivery_tips`), `start_date` and `end_date` (YYYY-MM-DD) the accepted names and values? Are the dates inclusive, and in which time zone? What does a request without dates return? | Sends `type`, and the dates only as a pair |
| 5 | **Errors:** what status and body come back for a bad filter (422?) and for an empty period (404?)? Are they in the normal `errors[]` envelope? | Shows the server message once, or a local text |
| 6 | **Size and time:** how large can a full statement get, and how long can generating it take? | 60 s timeout |

**Upload limits (added in D-09, questions only).** The app keeps one limit, `ImageUploadRules.maxImageBytes` = 2 MB per image, until these are answered. It is not changed by guessing.

| # | Question | What the app does today (D-09) |
|---|---|---|
| 7 | **nginx `client_max_body_size`:** what is it for `/api/v1/delivery-man/*`? What exactly does an oversize request get back (413 with an HTML body?) | Treats 413 on `delivered` with photos as too large: checks the order, then offers to deliver without photos |
| 8 | **PHP `upload_max_filesize` and `post_max_size`:** what are they? When `post_max_size` is exceeded PHP drops the whole body, so `_method=put` and every field are lost. Does update-order-status then answer 413 (Laravel `ValidatePostSize`), 405 (POST on a PUT route) or 403 validation (`order_id`)? | Treats 413 and 403 `order_id`/`status` as too large. A 405 is a plain failure (photos kept) |
| 9 | **Profile `image` rules:** what mimes and maximum size does `delivery-man/update-profile` accept, and what `errors[].code` does a refused image give? | Accepts jpeg, png, webp up to 2 MB; shows the server text for any 403 |
| 10 | **`order_proof[]` limits:** is there a per-file size or mime rule on the server (the validator shows only `array|max:5`)? What happens to a file the server cannot store: is `delivered` still written, and is the response still 200? | Sends at most 5 jpeg/png/webp photos of up to 2 MB each; checks `order_proof_full_url` only after a failed request |
| 11 | **Total size:** 5 photos of up to 2 MB can reach 10 MB, above the PHP default `post_max_size` of 8 MB. Should the app cap the total, and at what value? | No total cap |
