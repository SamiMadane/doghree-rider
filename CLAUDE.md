# CLAUDE.md: Doghree Rider

This is the Flutter delivery-man (rider) app for Doghree. Riders log in, go online, receive order requests, accept them, move each order through its statuses (with OTP and photo proof at delivery), chat with customers and stores, and see their wallet and earnings.

This file describes this repo only. The user app has its own docs, and none of its decisions apply here unless they are written below.

## Commands

```
flutter pub get
flutter analyze --no-pub     # baseline: 0 issues (see "Analyze baseline")
flutter test
flutter run
```

## Architecture

### State management and dependency injection (GetX)
- All registration happens in `lib/helper/get_di.dart` `init()`, which runs from `main()` before `runApp`.
- The order is: `SharedPreferences`, then `ApiClient`, then `SessionChecker`, then each feature's Repository (registered as its interface type), then its Service (registered as its interface type), then its Controller. Everything uses `Get.lazyPut`.
- Every feature controller is a `GetxController implements GetxService` and lives for the whole app. State survives navigation, so screens must reset what they need in `initState` (see `OrderDetailsScreen._loadData`).
- The UI rebuilds through `GetBuilder<XController>` plus `update()`. Rx/Obx is not used. Partial rebuilds use ids (for example `update(['order_map'])`).
- Services are also registered a second time as concrete classes (`get_di.dart` "/// Service" block). Controllers depend only on the `...ServiceInterface` registration. This duplicate is tracked in the D-00 audit.

### Feature layout
```
lib/features/<feature>/
  controllers/<feature>_controller.dart
  domain/models/
  domain/repositories/<feature>_repository(_interface).dart   # HTTP + SharedPreferences
  domain/services/<feature>_service(_interface).dart          # thin logic layer
  screens/
  widgets/                                                    # widgets used only by this feature
```
The features are address (zone list for registration), auth, chat, dashboard, forgot_password, home, html, language, notification, order, profile, splash, update and wallet.

The app-level folders are:
- `lib/api/`: ApiClient and error handling.
- `lib/common/`: app-wide widgets, `ConfigModel`, `ResponseModel` and `ThemeController`.
- `lib/helper/`: DI, routes, notifications, location permission, image picker, date and price converters.
- `lib/util/`: `AppConstants`, `Dimensions`, colours, styles, assets, `SessionChecker` and `Messages`.
- `lib/doghree_map/`: the map widget, which uses maplibre_gl first and falls back to flutter_map with PMTiles. Its settings come from `/api/v1/config`.
- `lib/theme/`: the light and dark themes.
- `lib/interface/`: the base `RepositoryInterface`.

### ApiClient (`lib/api/api_client.dart`)
- `ApiClient extends GetxService` uses `package:http`. The base URL is `AppConstants.baseUrl`.
- Headers: `Content-Type`/`Accept` JSON, `X-localization` set to the language code, and `Authorization: Bearer <token>` when a token exists. `updateHeader(token, languageCode)` rebuilds them; login, logout and the language change call it.
- `getData` (with an optional `query:` map that is URL-encoded by `Uri.replace`), `postData`, `putData`, `patchData` and `deleteData` all go through `_send`, which uses a 30s timeout. `postMultipartData` uses a 60s timeout and `_mediaType` picks png, webp, pdf, or jpeg as the default.
- Failure mapping happens in `_failure`. Socket, timeout and ClientException become `statusCode: 1` with `noInternetMessage`. Any other exception becomes `statusCode: 0` (unknown).
- `handleResponse` only treats 200 as success. For an error it builds `statusText` from the server message (`ApiErrorHandler.extractMessage`) or falls back to a localized `ErrorMessages` text.
  - When `handleError: true` (the default), a non-200 response is passed to `ApiChecker.checkApi`, which shows a toast or the session-expired sheet, and the caller receives an empty `Response()` (statusCode null).
  - When `handleError: false`, the caller receives the real response and is responsible for the message.
- `ApiChecker.checkApi` (`lib/api/api_checker.dart`): a 401 on non-`/auth/` paths clears the session (`AuthController.clearSharedData`, `ProfileController.stopLocationRecord`) and shows `SessionExpiredBottomSheet`, then goes to sign-in. Any other error shows `showCustomSnackBar`.
- `SessionChecker` (`lib/util/session_checker.dart`) polls the profile endpoint every 30s while the dashboard is alive.
- Many rider endpoints still send the auth token as a `?token=` query parameter or a `token` body field, in addition to the Bearer header (see `AppConstants` URIs ending in `?token=`).

### Start-up and routes
- `main()` runs `Firebase.initializeApp`, then `di.init()` (which loads `assets/language/{en,ar}.json`), then `getInitialMessage` → `NotificationHelper.initialize` → `onBackgroundMessage`, then date locale, then `LocationPermissionManager` (permanent), then `availableCameras()`, then `runApp`.
- `MyApp` uses `ScreenUtilInit(designSize: 376x812)` and `GetMaterialApp`. The initial route is `/language-init` on the first launch, otherwise `/navigation-handler?data=<base64 notification body>` (SplashScreen).
- `SplashScreen` (`features/splash/screens/splash_screen.dart`) runs `initSharedData`, then the connectivity listener, then `getConfigData`. On failure it shows `NoInternetScreen`. On success it checks the minimum version and maintenance mode (to `/update`), then validates the session via `getProfile`, then routes from the notification body or to dashboard or sign-in after the splash animation.
- Routes are in `lib/helper/route_helper.dart` as `RouteHelper` (24 `GetPage`s). Arguments travel as query parameters. Complex objects (notification body, chat user) are base64-encoded JSON. `/order-details` also accepts a prebuilt `OrderDetailsScreen` via `Get.arguments`.
- `DashboardScreen` hosts the 4 tabs (home, order requests, my orders, profile) in a `PageView`. It starts `SessionChecker` and listens to `FirebaseMessaging.onMessage` for new, assigned and block events.

### Firebase and notifications (`lib/helper/notification_helper.dart`)
- Firebase core and messaging are used. `firebase_auth` is used for phone verification in forgot-password.
- After login and on splash, `updateToken()` (auth repository) asks for iOS permission, gets the FCM token, subscribes to topics (`all_zone_delivery_man`, zone topic and vehicle topic from the login response), and PUTs `update-fcm-token`. Logout unsubscribes and sends the same call without `fcm_token`.
- In the foreground, `onMessage` in NotificationHelper shows a local notification and refreshes orders, notifications, chat or wallet by `type`. The dashboard has its own `onMessage` listener that shows the order-request bottom sheet.
- Taps: `onDidReceiveNotificationResponse` (local), `onMessageOpenedApp`, and `getInitialMessage` (cold start, via splash) each map `NotificationType` to a route.
- In the background, `myBackgroundMessageHandler` handles `assign`, `new_order` and `order_request` by starting a `flutter_foreground_task` service that plays `notification.mp3` every 5s. Data-only messages on Android are shown as local notifications.

### Local storage
Everything is in `SharedPreferences`. The keys are in `AppConstants` ("Shared Key" block): token, language and country codes, theme, notification toggle, seen notification ids and count, the ignored order requests (`ignoreList`, JSON strings with a timestamp), FCM topics, the remember-me phone and password, and the logout reason. There is no secure storage.

### Orders (`features/order`)
- Lists in `OrderController`:
  - `latestOrderList`: open requests. `available_orders_screen` polls it every 10s. Ignored ids are filtered out.
  - `currentOrderList`: running orders.
  - `completedOrderList`: history, paginated with `offset`/`limit=10`, using `_offsetList` to avoid duplicates.
  - Orders without items are filtered out (`_isValidOrder`) unless they are parcels.
- Actions:
  - `acceptOrder` (PUT `accept-order`).
  - `updateOrderStatus`: multipart POST `update-order-status` with status, OTP (on delivered, and on parcel pickup) and proof images (`_pickedPrescriptions`, at most 5, quality 70, max width 1600).
  - Cancel: `updateOrderStatus` with `canceled` plus a reason from `cancellation-reasons`.
  - `ignoreOrder`: local only.
- `OrderDetailsScreen` polls `getOrderWithId` every 10s until a final status (delivered, failed, canceled or refunded). It pauses while the app is backgrounded.
- Map preview: `initOrderMap` gets the current position, falls back to the last recorded location, and gets a route from `/api/v1/config/direction-api`.
- Location: once the rider is online (`profile.active == 1`), `ProfileController.startLocationRecord` posts the position every 10s. Depending on `config.webSocketStatus` it uses `record-location-data` or the WebSocket. The place name comes from `/api/v1/config/geocode-api`.

### Wallet and earnings (`features/wallet`)
- Wallet: `GET /delivery-man/wallet` returns the balance and accounts. The rider can add or delete payout accounts, request a withdrawal (`wallet/withdraw`) and list withdrawals (`wallet/withdrawals`, first 20).
- Earning report: `GET earning-report` with `limit=10&offset&type&start_date&end_date`, paginated with request-id guarding and retry on failure. The filter is a type (all, delivery_fee or delivery_tips) and a date range.
- Invoice: `GET /deliveryman-earning-report-invoice/{dmId}` with the same filters. The PDF is saved to the documents directory and opened with `open_filex`.

## Working rules

### Sizes come from `Dimensions`
- `lib/util/dimensions.dart` is a class of `static double` fields computed with flutter_screenutil extensions against the 376x812 design:
  - fonts: `fsNN = NN.sp`
  - heights and vertical spacing: `hNN = NN.h`
  - widths and horizontal spacing: `wNN = NN.w`
  - radii: `rNN = NN.r`
  - plus a few true constants (`webMaxWidth`, `messageInputLength`, `pickMapIconSize`).
- Widgets use only these fields: `Dimensions.h16`, `Dimensions.w10`, `Dimensions.fs14`, `Dimensions.r12`.
- No raw numbers in widgets (`height: 40`, `EdgeInsets.all(16)`, `BorderRadius.circular(24)`), and no inline `.w`/`.h`/`.sp`/`.r` in widget code.
- If a size is missing, add a field to `Dimensions` that follows the same pattern (`static double h44 = 44.h;`) and use it. Name and value must match.
- Existing raw numbers are fixed when a batch touches that widget. Do not sweep unrelated files.

### File structure
- A widget used by one feature goes in `lib/features/<feature>/widgets/`.
- A widget used by two or more features goes in `lib/common/widgets/`. Move it there when a second feature needs it, rather than importing across features.
- Screens go in `screens/`, logic in controllers, services and repositories. No HTTP calls from widgets or controllers. Repositories own `ApiClient`.
- No loose files at a feature root. No new top-level folders under `lib/` without a reason recorded in `docs/progress.md`.

### Messages, loaders and errors
- **One toast helper.** Every toast goes through `showCustomSnackBar` (`lib/common/widgets/custom_snackbar_widget.dart`). Do not add new direct `Get.snackbar`, `Get.showSnackbar` or `ScaffoldMessenger.showSnackBar` calls. Existing ones are migrated when touched.
- **One message per user action.** A tap produces at most one message, success or error. If the repository uses `handleError: true`, `ApiChecker` already showed the error, so the controller must not show another. If the controller shows its own message, the call uses `handleError: false`.
- **Silent background work.** Polling, location recording, FCM token updates, session checks, mark-as-read and refreshes after an action never show a toast on failure. Use `handleError: false` and ignore or log in debug only.
- **No internet.** A screen whose first load fails because there is no internet (`statusCode == 1`) shows the compact `NoInternetScreen` with a Retry button that reruns that load. It does not show a stack of toasts. Background calls stay silent offline.
- **Loaders always stop.** Every `_isLoading = true` has a matching reset on every exit path. Use `try/finally` or reset before each early `return`, including 404, stale and exception paths.

### Backend
- The app adapts to the backend as it is. When a fix needs a backend change (for example removing the token from URLs), add a row to **docs/progress.md → Open backend questions**. Do not work around it in code, and do not add it to `docs/backend-changes.md` until the owner agrees. After agreement, it moves to `docs/backend-changes.md`.
- `docs/api-contract.md` records endpoints as they are actually observed (request and response shape).
- `docs/code-traps.md` records non-obvious pitfalls found while working.

### Analyze baseline
- Measured on 2026-11-14 at `development` dcaf6d5: `flutter analyze --no-pub` reported **No issues found (0)**.
- A batch must leave analyze at 0. Run it before every commit and report the number.

### Git
- Commit messages are written to a file in the scratchpad, UTF-8 **without BOM** and **without double quotes**, then committed with `git commit -F <file>`.
- Stage explicit paths only. **Never stage `.claude/`.**
- **Never push.** The local merge is the only merge step Claude does (see Batch workflow, step 6).

### Privacy
- Never copy tokens, phone numbers, emails, OTPs or real coordinates into docs, audit tables, commit messages or replies. Describe them instead (for example: token appears in URL query).
- Audit severity values are crash, wrong data, privacy (tokens or personal data in URLs or logs), bad UX and minor.

## Batch workflow
1. Each batch runs on its own branch `fix/d-xx-short-name`, created from a clean `development` that is level with `origin/development` (`git fetch`, then confirm `git status` is clean and HEAD equals `origin/development`).
2. **Plan mode first.** Present the plan: scope, files, tests, device steps. No implementation before the owner approves the plan.
3. Implement. Add unit tests where logic allows. Every new test must fail on the old code. Check this by running it against the pre-fix code and say which tests failed there.
4. Report after implementation:
   - test counts (total, passed, failed) for the new tests and the full suite
   - analyze count against the baseline (0)
   - the new tests that fail on the old code
   - exact device test steps, saying which items are covered by unit tests only
5. The user runs the device tests.
6. After the user's device tests pass, Claude Code acts on the user's closing message:
   - makes a docs-only commit updating `docs/progress.md` and `docs/backend-changes.md`
   - runs `git checkout development` and `git merge --no-ff <branch>` locally
   - shows `git log --oneline -8 --graph` and `git status`
   - prints the push command
   Claude Code never pushes. The user runs `git push origin development`.
7. The next batch starts in a new session.
