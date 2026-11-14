# Code traps

Non-obvious pitfalls in this codebase. Add an entry when one costs time.

| Trap | Where | Why it bites | Safe pattern |
|---|---|---|---|
| `flutter run` / `flutter test` regenerate plugin registrants | macos/Flutter/GeneratedPluginRegistrant.swift, windows/flutter/generated_plugin_registrant.cc, windows/flutter/generated_plugins.cmake | They show up as modified after any Flutter run and can slip into a batch commit | Never stage them in a batch. `git restore` them before merging (D-01) |
| Logout FCM call must run while the header still holds the token | lib/features/auth/domain/repositories/auth_repository.dart `clearSharedData` | Since D-02 the rider token goes only in the Bearer header. `postData` takes the headers synchronously when it is called, so `update-fcm-token` must start before `remove(token)` and `updateHeader(...)`. If it is moved after them, or behind an earlier await that clears the header, it goes out without auth (401) and the server keeps the device token | Start the call before clearing the token and header. Use `handleError: false`, so a 401 during logout never opens the session-expired sheet (D-02) |
| `ProfileModel.fromJson` throws on a missing list | lib/features/profile/domain/models/profile_model.dart (`identity_image_full_url`) | `json['identity_image_full_url'].cast<String>()` throws when the field is null or missing, so a 200 response can still fail to parse | Callers must catch parse errors. `ProfileRepository.getProfileInfo` maps a parse error to `SessionStatus.unverified` (D-01). Tests must include the field |
