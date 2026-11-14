# Backend reference files

Copies of the backend team's reference material, kept here so batches can be planned against them. These files are read-only: do not edit them, but replace them when a newer version arrives and update this README.

**The reference files are local only (gitignored) and are read from disk.** Only this README is committed. If they are missing on a machine, ask the user for copies.

## Files

| File | What it is | Date |
|---|---|---|
| `Doghri-App-Screens.html` | Screen-by-screen map of the Doghri apps to the endpoints they call, with request and response shapes. The rider section is **R1-R7**: login, offered orders board, claim or refuse, delivery steps, wallet, weekly withdrawal, deposit (off). Appendix A1 lists where the code and the docs disagree. | Live-verified against the server on 2026-10-14 |
| `Doghri-API-Guide.pdf` | Written API guide, version 3. It covers auth, flows and endpoint descriptions for all apps. | v3, 2026-10-11 |
| `Doghri.postman_collection.json` | Postman collection "API (v3)" with request examples and some saved example responses. The collection variables for tokens are empty, so fill them locally and never commit filled values. | 2026-10-11 |

## Order of authority

When the files disagree, trust them in this order:

1. **`Doghri-App-Screens.html`** is the newest file and was checked against the live server on 2026-10-14. For rider work, start with sections R1-R7.
2. **`Doghri-API-Guide.pdf`** (v3, 2026-10-11) comes second. Its note that the rider wallet is not live is **outdated**: the wallet is live (see R5 and R6 in the screens file).
3. **`Doghri.postman_collection.json`** is used only for request examples (headers, body fields, parameter names). It is not a source of truth for behaviour or response shape.

If the app's observed behaviour differs from all three, record what was observed in `docs/api-contract.md`. If it needs a backend change, add it to the open backend questions in `docs/progress.md`.

## How to use them

Before planning any batch that touches an endpoint, look up that endpoint here (R1-R7 first) and check the plan against it. This rule is also in `CLAUDE.md` under Backend.
