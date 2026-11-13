# Donexia Flutter — Build Report

Date: 11 Nov 2026, updated 13 Nov 2026. App name: **Donexia** (not Udaar).

## 13 Nov 2026 ~11:30 IST — GitHub Actions resumed after token fix: STILL BLOCKED at repo creation, NO APK

User confirmed ("kar diya") they updated the fine-grained token: Repository access = All repositories (already selected in their screenshot), Contents = Read and write, Actions = Read and write added, Update clicked. Token was NOT regenerated.
- Verified access again: `GET /user` → **iamcaravi** (Ravi Mishra) — token works.
- `GET /repos/iamcaravi/Donexia` → **404 Not Found** (repo still does not exist).
- `POST /user/repos` (create public repo `Donexia`, auto_init false) → **403 `Resource not accessible by personal access token`** — same error as before the fix.
- Stopped there per instructions; no push, no workflow run, no APK. Nothing was changed on GitHub.
- Interpretation: the token fix did not unblock repo creation. Fine-grained personal access tokens cannot create repositories via the REST API at all (repo creation is not a repository-scoped permission — `POST /user/repos` is not available to fine-grained tokens), so no token permission change will fix this step.
- **Next step the user must do:** create the empty public repo themselves at https://github.com/new — Repository name `Donexia`, Public, do NOT add a README/.gitignore/license (leave all unchecked) — then tell Muse to resume. Once the repo exists, the token (All repositories + Contents RW + Actions RW) should be able to push via the git-database API and dispatch the workflow. If the push then still returns 403, that is a separate, reportable error.
- Workflow file is ready in the project: `.github/workflows/build-apk.yml` (push to main / workflow_dispatch → flutter pub get, analyze, test, build apk --release, upload artifact `donexia-app-release`).

## 13 Nov 2026 ~11:22 IST — GitHub Actions attempt: BLOCKED at repo creation, NO APK

User asked "github par banaye toh?" — attempted to build the APK on GitHub Actions instead of the VM.
- Verified access: `GET /user` → **iamcaravi** (Ravi Mishra).
- `GET /repos/iamcaravi/Donexia` → **404 Not Found** (repo does not exist).
- `POST /user/repos` (create public repo `Donexia`, auto_init false) → **403 `Resource not accessible by personal access token`**.
- Stopped there per instructions; no push, no workflow run, no APK. Nothing was changed on GitHub.
- Cause: the fine-grained token is limited to Repository access = **iamcaravi/YOYOPDF only** (Oct 2026), so it cannot create a new repo or access a repo it was not granted.
- **Fix the user must make on GitHub** (same as the 27 Oct 2026 YOYOPDF token fix): open the fine-grained token (https://github.com/settings/tokens?type=beta), Edit it, and either (a) change Repository access to **All repositories**, or (b) keep "Only select repositories" and add **Donexia** to the list — with Repository permissions **Contents: Read and write** and **Actions: Read and write** (Actions write is needed to dispatch the workflow; Contents write is needed to push). Then tell Muse to retry. Alternatively, the user can create the empty public repo `iamcaravi/Donexia` themselves on github.com and tell Muse — the token still needs Donexia added to its repository access before any push will work.
- Workflow file is ready in the project: `.github/workflows/build-apk.yml` (push to main / workflow_dispatch → flutter pub get, analyze, test, build apk --release, upload artifact `donexia-app-release`). Once the repo exists and the token can access it, the remaining steps are: push via the git-database API, dispatch the workflow, poll the run, download the artifact.

## 13 Nov 2026 — resumed build (after 11 Nov stop + runtime restart)

Toolchain now installed on this VM and verified working: **Flutter 3.50.0 stable, Dart 3.14.0, OpenJDK 17.0.21, Android SDK (~1 GB: build-tools, cmdline-tools, platforms, NDK, licenses)** at `~/flutter` and `~/Android/Sdk`. Full project scaffolding generated (`android/ ios/ web/ linux/ macos/ windows/`, `.dart_tool/`, `pubspec.lock`).

Verified this session (run, not claimed):
- `flutter analyze` → **No issues found!**
- `flutter test` → **3/3 tests passed** (1% fee math + seed data)
- `flutter build apk --release` → **FAILED, no APK exists.** See blocker below.

## Blocker: NO APK — sandbox blocks JVM TCP (`other_tcp` = Deny)

`flutter build apk` fails every time at the Gradle daemon step:

```
Running Gradle task 'assembleRelease'...
Could not dispatch a message to the daemon.
Caused by: java.io.IOException: Connection reset by peer
```

Root cause, proven with a controlled test (matrix: Python→Python OK, Python→Java OK, Java→Python FAIL, Java→Java FAIL): **any TCP connection initiated by a JVM process is intercepted by this VM's sandbox**, which replies with:

> muse: Other TCP connections is turned off for this assistant. To allow it, ask the user to open Muse settings -> Permissions -> Direct network protocols and switch other_tcp from Deny to Ask.

Gradle builds always run through a daemon JVM talking to its client over loopback TCP, so **no Gradle/Android build can succeed on this VM while `other_tcp` is Deny**. This is a sandbox permission, not a code, RAM or Gradle problem — do NOT try to bypass it. Loopback TCP itself works (Python test passed); only JVM-originated TCP is blocked.

Two secondary issues found and FIXED this session (so the next attempt gets further):
1. **Ancient Gradle wrapper jar**: the project's `android/gradle/wrapper/gradle-wrapper.jar` is Gradle **2.10** (2015; same jar Flutter itself ships). It computes a different distribution-dir hash (`aca6g93cdtcf0oapcfka748qh`) than the cached Gradle 9.5.0 dir, so it always tried to re-download Gradle through the proxy and failed. Fixed by pre-populating that expected dir with the already-downloaded Gradle 9.5.0 zip + `.ok` marker + extracted distribution, in both `/home/hatch/.gradle` and `/root/.gradle`. Verified: `./gradlew --version` now prints Gradle 9.5.0 with no download. (The 2.10 wrapper jar itself was left in place — it is only a bootstrapper and now finds its distribution.)
2. **Gradle daemon registry/home**: the wrapper resolves its home from Java's `user.home` (`/root` for root) unless `GRADLE_USER_HOME` is set. Always run builds with `GRADLE_USER_HOME=/home/hatch/.gradle`. Low-memory settings already in place: `android/gradle.properties` has `-Xmx512m`, `org.gradle.workers.max=1`, `org.gradle.parallel=false`; `~/.gradle/gradle.properties` has the VM egress-proxy settings (password rotates per session — refresh it from `$HTTPS_PROXY` if a build fails on proxy auth).

## Exact next step to get the APK

1. User opens **Muse settings → Permissions → Direct network protocols** and switches **`other_tcp` from Deny to Ask** (and approves when asked).
2. Then, on this VM, run:
```bash
cd ~/workspace/donexia-flutter
export PATH="$HOME/flutter/bin:$PATH"
export GRADLE_USER_HOME=/home/hatch/.gradle
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```
3. If the build then fails on dependency downloads, refresh the proxy password in `~/.gradle/gradle.properties` from the current `$HTTPS_PROXY` value and retry. Full log of the last attempt: `build-apk.log` in this folder.
4. Alternative without this VM: copy this folder to any machine with Flutter + Android Studio and run the same commands — the code itself is verified clean (analyze + tests pass).

## What was created

`~/workspace/donexia-flutter/` — complete Flutter source scaffold:

- `pubspec.yaml` — package `donexia` 1.0.0+1, Flutter ≥3.22, deps: provider, shared_preferences, sqflite, intl, image_picker, share_plus, qr_flutter, google_fonts, cached_network_image
- `analysis_options.yaml`, `.gitignore`
- `lib/main.dart` — MaterialApp, en/hi locales, all routes, admin route guard (non-admins see a lock screen)
- `lib/models/` — `campaign.dart` (categories, 8 statuses, `isPublic` only for Approved/Active, `PaymentDestination` kept separate/private), `user.dart` (roles Donor/HelpSeeker/Admin, `Donation` with 1% fee math + receipt ID), `bank.dart` (17 default banks/NBFCs)
- `lib/data/` — `seed_data.dart` (10 realistic campaigns incl. SBI ₹2,40,000 Kanpur loan example), `local_store.dart` (SharedPreferences JSON persistence, seed-on-first-launch, donation application to campaign totals, demo reset)
- `lib/services/` — `app_state.dart` (Provider state, filtering/sorting, totals), `auth_service.dart` (demo OTP `123456`, demo admin phone `9999999999`)
- `lib/screens/` (12) — splash, onboarding (3 slides), auth (demo OTP, labelled), register, home (greeting/search/categories/Featured/Recent/Most Needed/totals/bottom nav + Create Campaign FAB), explore (category/state/district/verified/sort/search), campaign_detail (privacy banner, no account/Aadhaar/PAN/medical docs), create_campaign (6-step Stepper wizard), donate (₹10/50/100/500/1000 + custom, UPI/QR/Card/Net Banking demo, 1% fee breakdown, receipt screen), my_donations, profile, admin (Review/Banks/Transactions/Analytics tabs)
- `lib/widgets/` — `campaign_card.dart` (card + category chips + INR formatting), `progress_bar.dart` (progress bar + `DemoBanner`)
- `lib/l10n/strings.dart` — Hindi/English strings
- `lib/utils/` — `theme.dart` (exact palette #168653/#22A06B/#FFFFFF/#F3FAF6/#202B25/#DC2626), `format.dart`
- `test/` — `fee_test.dart` (1% fee: ₹100→₹1, ₹1000→₹10; split ₹1000→₹990), `seed_test.dart` (≥8 campaigns, cmp_001 = ₹2,40,000 Kanpur SBI loan)
- `android/app/src/main/AndroidManifest.xml` — app label Donexia, INTERNET permission, launcher activity (stub only — see below)
- `README.md` — full build + demo-login instructions

## Demo credentials

- Any user: any 10-digit phone + OTP `123456` (shown on screen; no SMS sent)
- Admin: phone `9999999999` + OTP `123456` → Admin Panel

## What was NOT verified (11 Nov, now superseded — see 13 Nov section above)

- ~~Flutter/Dart are NOT installed on this VM~~ — installed 12–13 Nov (Flutter 3.50.0, Dart 3.14.0); `flutter analyze` and `flutter test` now run and pass.
- **`flutter build apk` was NOT attempted and NO APK exists** (11 Nov). Attempted 13 Nov — failed on the `other_tcp` sandbox block, see above. **Still no APK.**
- `android/` was a manifest stub only on 11 Nov — full scaffolding has since been generated (`flutter create .` equivalent).
- Seed images are `picsum.photos` placeholders, not real beneficiary photos.

## Exact commands to build the APK (on a machine with Flutter)

```bash
cd ~/workspace/donexia-flutter
flutter pub get
flutter analyze
flutter test
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
# Install: adb install build/app/outputs/flutter-apk/app-release.apk
```

## File tree

```
donexia-flutter/ (~/workspace/donexia-flutter/)
├── README.md  BUILD_REPORT.md  pubspec.yaml  analysis_options.yaml  .gitignore
├── android/app/src/main/AndroidManifest.xml
├── assets/ (images/, icons/ — empty placeholders)
├── lib/
│   ├── main.dart
│   ├── models/campaign.dart  user.dart  bank.dart
│   ├── data/seed_data.dart  local_store.dart
│   ├── services/app_state.dart  auth_service.dart
│   ├── screens/ splash onboarding auth register home explore
│   │   campaign_detail create_campaign donate my_donations profile admin
│   ├── widgets/campaign_card.dart  progress_bar.dart
│   ├── l10n/strings.dart
│   └── utils/theme.dart  format.dart
└── test/fee_test.dart  seed_test.dart
```
