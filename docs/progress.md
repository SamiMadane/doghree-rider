# Progress

## Batch status

| Batch | Branch | Scope | Status | Merged |
|---|---|---|---|---|
| D-00 | docs/d-00-setup | CLAUDE.md, docs skeleton, audit | done | |
| D-01 | fix/d-01-startup | Audit rows 1, 2, 3, 4, 5, 7, 59 | planned | |
| D-02 | fix/d-02-silent-network | Audit rows 8, 9, 10, 11, 12, 13, 50, 51 | planned | |
| D-03 | fix/d-03-auth | Audit rows 14, 15, 16, 17, 18 | planned | |
| D-04 | fix/d-04-order-actions | Audit rows 19, 20, 21, 22, 23, 24, 25, 28, 29 | planned | |
| D-05 | fix/d-05-order-lists-parsing | Audit rows 26, 27, 30, 52, 53 | planned | |
| D-06 | fix/d-06-location-ringing | Audit rows 36, 37, 38, 39 | planned | |
| D-07 | fix/d-07-notifications | Audit rows 6, 31, 32, 33, 34, 35, 54 | planned | |
| D-08 | fix/d-08-wallet | Audit rows 41, 42, 43, 44 | planned | |
| D-09 | fix/d-09-uploads-profile | Audit rows 45, 46, 47, 48, 49 | planned | |
| D-10 | fix/d-10-cleanup | Audit rows 40, 55, 56, 57, 58, 60 | planned | |

## Batch log

<!-- One section per batch: date, what changed, tests (new / total / failing on old code), analyze count, device steps and result. -->

### D-00 (2026-11-14)
- Created CLAUDE.md, docs/progress.md, docs/backend-changes.md, docs/code-traps.md, docs/api-contract.md and docs/audit-d00.md (60 findings, batches D-01 to D-10).
- Added open backend questions B-01 to B-04.
- Docs only, no app code changed.
- Analyze: 0 issues (`flutter analyze --no-pub` at dcaf6d5).
- Tests: none run. The only test is the stale default counter test, which cannot pass (audit row 59, D-01).

## Open backend questions

<!-- The only place new backend questions are recorded. Move a row to docs/backend-changes.md once the owner agrees. -->

| ID | Endpoint | Question / needed change | Why | Raised in | Status |
|---|---|---|---|---|---|
| B-01 | /api/v1/delivery-man/* (current-orders, latest-orders, all-orders, order, order-details, profile, remove-account, earning-report, message/*) | Can these accept the Bearer header only, so the app stops sending `?token=` in URLs and `token` in bodies? | Tokens in URLs end up in server, proxy and CDN logs (audit row 9) | D-00 | open |
| B-02 | /api/v1/delivery-man/update-order-status | When `dm_picture_upload_status` is on, is a delivery photo mandatory? Does the server reject `delivered` without `order_proof`? | The app shows the photo section but never requires it (audit row 49) | D-00 | open |
| B-03 | /api/v1/delivery-man/wallet/withdrawals | Does the response include a total count for paging past `limit=20`? | Older withdrawals are never shown (audit row 42) | D-00 | open |
| B-04 | /deliveryman-earning-report-invoice/{id} | What Content-Type and charset does the PDF response use? | The app saves decoded text as bytes, so a utf-8 charset would corrupt the file (audit row 41) | D-00 | open |
