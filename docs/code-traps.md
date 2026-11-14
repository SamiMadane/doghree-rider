# Code traps

Non-obvious pitfalls in this codebase. Add an entry when one costs time.

| Trap | Where | Why it bites | Safe pattern |
|---|---|---|---|
| `flutter run` / `flutter test` regenerate plugin registrants | macos/Flutter/GeneratedPluginRegistrant.swift, windows/flutter/generated_plugin_registrant.cc, windows/flutter/generated_plugins.cmake | They show up as modified after any Flutter run and can slip into a batch commit | Never stage them in a batch. `git restore` them before merging (D-01) |
| `ProfileModel.fromJson` throws on a missing list | lib/features/profile/domain/models/profile_model.dart (`identity_image_full_url`) | `json['identity_image_full_url'].cast<String>()` throws when the field is null or missing, so a 200 response can still fail to parse | Callers must catch parse errors. `ProfileRepository.getProfileInfo` maps a parse error to `SessionStatus.unverified` (D-01). Tests must include the field |
