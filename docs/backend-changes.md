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
