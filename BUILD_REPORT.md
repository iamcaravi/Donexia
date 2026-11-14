# Donexia Flutter — Build Report

Date: 11 Nov 2026, updated 13 Nov 2026. App name: **Donexia** (not Udaar).

## 14 Nov 2026 ~02:07 IST — Run #6 SUCCESS — APK BUILT ✅

- **Run #6 — https://github.com/iamcaravi/Donexia/actions/runs/43500200048 — SUCCESS** (started 20:17:34 UTC, completed 20:24:13 UTC, ~7 min). All steps passed: checkout, Java 17, Flutter stable, pub get, Analyze, Test 3/3, Build release APK, Upload artifact.
- **Fix applied (commit `1f8db37a876a0309d3e1c28722033aca6d7ce55e` on main, parent `3e058f52`):** `android/app/build.gradle.kts` — added `android { lint { checkReleaseBuilds = false } }` (standard for Flutter release builds; `flutter analyze` already covers static analysis). This disables the release lint gate that crashed in run #5 (`:image_picker_android:lintVitalAnalyzeRelease`, `List.removeLast()` Java 21 API on JDK 17). Pushed via git-database API (blob `cf844dfa`, tree `27763fdf`), ref verified, file verified in repo. Push auto-triggered the run; no dispatch sent. No app code changed.
- **APK — 52 MB (54,091,500 bytes), Android package verified with `file`:** `Android package (APK), with gradle app-metadata.properties`. MD5 `7d90b9ff444c06f4854bb25354538bdb` (identical in both locations).
  - `~/workspace/donexia-flutter/build/app/outputs/flutter-apk/app-release.apk`
  - `~/workspace/Donexia-app-release.apk`
  - Artifact `donexia-app-release` (id 14074750240, 25,304,353-byte zip) downloaded from the run; first download attempt failed (RemoteDisconnected from the blob host after ~10 min) — retry via the presigned-URL streaming download succeeded in ~12 s.
- **Done.** No further build needed unless app code changes.

## 14 Nov 2026 ~01:15 IST — Run #5 FAILED in ~9 min at lint, NO APK — OOM is FIXED, new blocker is AGP 9 lint crashing on JDK 17

- **Run #5 — https://github.com/iamcaravi/Donexia/actions/runs/43495277388 — FAILURE** (completed 19:55 UTC, ~9 min total). Steps 1–7 all SUCCESS (checkout, Java 17, Flutter stable, pub get, Analyze, Test 3/3). Step 8 "Build release APK" FAILED; step 9 Upload skipped.
- **Fix applied (commit `3e058f524dd5c4553683dbb9422f3076f3ef546f` on main, parent `b25ba53a`):** `android/gradle.properties` — `org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g -XX:ReservedCodeCacheSize=512m` (was `-Xmx512m`). Pushed via git-database API (blob `47bf69db`, tree `bf330f1e`), ref verified, file verified in repo. Push auto-triggered the run; no dispatch sent. No app code changed.
- **OOM is gone:** the full job log (52,106 lines, fetched via the presigned job-logs URL — direct download from `productionresultssa32.blob.core.windows.net` times out from this VM, browser fetch works) contains **zero** `OutOfMemoryError` matches. The heap fix worked; R8 was never reached.
- **New failure point — log lines 51350–51366:** `FAILURE: Build failed with an exception.` → `Execution failed for task ':image_picker_android:lintVitalAnalyzeRelease'` → `Unexpected failure during lint analysis of ExifDataCopier.java` → `NoSuchMethodError: 'java.lang.Object java.util.List.removeLast()'` — crash inside detector `com.android.tools.lint.checks.CommentDetector` (stack: `JavaDocParser.parseDataItem` / `JavaParserUtil.parseFragment`). `List.removeLast()` is a Java 21 `SequencedCollection` API — it does not exist on Java 17.
- **Root cause:** project uses AGP **9.3.1** (settings.gradle.kts) + Kotlin 2.4.20, runner JDK is 17 (setup-java@v4, temurin 17.0.21). AGP 9.x's bundled lint tooling was built against Java 21 APIs, so `lintVitalAnalyzeRelease` (the release-build lint gate, run for the `image_picker_android` library dependency) crashes on JDK 17. This is a lint-tooling/JDK mismatch, not app code — `flutter analyze` and tests pass.
- **No APK built, no artifact to download.**
- **Recommended fix for run #6 (NOT yet applied — needs parent go-ahead):** disable the release lint gate in `android/app/build.gradle.kts` — `android { lint { checkReleaseBuilds = false } }` (standard for Flutter release builds; `flutter analyze` already covers static analysis). Alternative: switch the workflow to Java 21 — riskier, AGP 9.3.1/Flutter 3.50 template expects 17. Do NOT run `flutter build apk` on this VM.

## 14 Nov 2026 ~01:05 IST — Run #4 CANCELLED after ~90 min hung Gradle build, NO APK — ROOT CAUSE FOUND (Java heap too small for R8)

- **Run #4 — https://github.com/iamcaravi/Donexia/actions/runs/43479089450 — CANCELLED** (conclusion `cancelled`, I cancelled it via the API at ~19:33 UTC after ~89 min; step 8 "Build release APK" had been `in_progress` since 18:06 UTC, no step change after 18:08). Analyze SUCCESS, Test SUCCESS (3/3) — code is fine.
- **Workflow change (commit `b25ba53aa76513ac4e0b6c80ae70d07279f2d75e` on main):** `flutter build apk --release --verbose` + `GRADLE_OPTS="-Dorg.gradle.daemon=false"`. Verified in repo. The push auto-triggered the run, so no separate workflow_dispatch was sent (a dispatch would only have duplicated it). `--verbose` worked — the hang point is now visible.
- **Log diagnosis (full job log fetched, 18,809 lines, 2.66 MB, /tmp/donexia-run4-logs.txt):**
  - 18:06:17 build step starts; 18:10:27 `:app:minifyReleaseWithR8` (R8 9.3.16) starts. The Flutter file-watcher exception (`Already watching path: .../flutter_tools/gradle`) appears again at 18:10:29 — but the build continued past it, so it is a red herring, not the hang.
  - 18:14:23 AAPT2 daemon shutdown — last normal output. **18:14:23 → 19:09:50: zero output for 55 min.**
  - 19:09:50 `Exception in thread "RMI TCP Connection(idle)" java.lang.OutOfMemoryError: Java heap space` — the Gradle daemon JVM ran out of heap while R8 was still running. 19:33:39 I cancelled the run.
  - **Root cause:** `android/gradle.properties` sets `org.gradle.jvmargs=-Xmx512m` (a low-RAM VM setting from 13 Nov, carried into the GitHub build). Log line 530 confirms the daemon was forked with `-Xmx512m`; Gradle warned dozens of times "Increase max heap size of Gradle build process to reduce cache misses." R8 code-shrinking needs far more than 512 MB — it GC-thrashed for ~55 min, then OOM'd. Run #3 almost certainly died the same way (same heap, same step, no verbose output to show it). The Gradle daemon stall theory is dead: the daemon was alive and working, it just had no heap.
- **No APK built, no artifact to download.**
- **Recommended fix for run #5 (NOT yet applied — needs parent go-ahead):** raise the heap in `android/gradle.properties` — `org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g ...` (GitHub `ubuntu-latest` runners have 16 GB RAM). Keep `--verbose` + daemon=false in the workflow. That is a build-config change, not app-code change. The VM-era `org.gradle.workers.max=1` / `parallel=false` can stay or be dropped; they are not the cause.

## 13 Nov 2026 ~23:22 IST — Run #3 CANCELLED after ~96 min hung Gradle build, NO APK

- **Run #3 — https://github.com/iamcaravi/Donexia/actions/runs/43461033947 — CANCELLED** (conclusion `cancelled`, I cancelled it via the API at ~17:52 UTC after it sat on step 8 for ~96 min total; step 8 "Build release APK" had been `in_progress` since 16:17:36 UTC). Analyze SUCCESS, Test SUCCESS (3/3) — the code is fine; the hang was in the Gradle build phase.
- **Log diagnosis (full job log fetched, 463 lines, /tmp/donexia-run3-logs.zip — note: GitHub returned it as plain text, not a zip):**
  - 16:17:36 `flutter build apk --release` starts; 16:19:15 Gradle task `assembleRelease` starts; 16:19:16–37 Android SDK installs NDK 28.2 (download + unzip complete, 100%).
  - 16:20:34 KGP warning only (share_plus applies Kotlin Gradle Plugin — warning, not an error).
  - 16:21:40 last output line: `Caught exception: Already watching path: /opt/hostedtoolcache/flutter/stable-3.50.0-x64/flutter/packages/flutter_tools/gradle` — the Flutter tool's file watcher threw.
  - 16:21:40 → 17:52:20 **complete silence (~90 min)** while the build was still "running". At cancellation, orphan processes were still alive: 1 Dart (`flutter_tools`) + 4 Java (Gradle daemons). So Gradle daemons were alive but made no progress and printed nothing for ~90 min.
  - **Diagnosis:** not a code error and not a dependency failure — the Flutter tool's Gradle-output handling broke after the file-watcher exception, and the Gradle build itself stalled with no output (most likely stuck in dependency download/configuration with stdout swallowed, or a Gradle-side stall). No error message was ever produced.
- **No APK built, no artifact to download.** Nothing was re-pushed.
- **Suggested next attempt (parent to decide):** re-run the same workflow with `flutter build apk --release --verbose` (so the hang point is visible in the log) and/or add `--no-daemon` / `org.gradle.daemon=false` to the Gradle invocation; if it hangs again at the same place, suspect the Flutter 3.50.0 file-watcher bug and try pinning an older Flutter (e.g. 3.32/3.35) in the workflow. Do NOT run `flutter build apk` on this VM (sandbox still blocks JVM TCP).

## 13 Nov 2026 ~21:27–22:45 IST — Workflows permission added, workflow file pushed, run #3 STILL BUILDING (no APK yet)

- User confirmed ("Kar diya") they added **Workflows: Read and write** to token `muse`. Verified: `GET /user` → iamcaravi.
- **Workflow file pushed:** `.github/workflows/build-apk.yml` committed on top of main via git-database API — commit `c1258d623f6c4fd0f8e84e7b45806dad06f92a1f`, main ref verified, file present in repo (blob `6d3d57`, 1097 bytes). The push auto-triggered run #1; no separate dispatch was needed.
- **Run #1 — https://github.com/iamcaravi/Donexia/actions/runs/43457880887 — FAILURE** at step 6 Analyze: 134 errors, all `uri_does_not_exist` / undefined identifiers. Root cause: the 13 Nov storage cleanup had deleted 11-Nov-dated source files from the workspace BEFORE the 17:30 push, so the repo was missing `lib/models/` (bank/campaign/user), `lib/data/` (local_store/seed_data), `lib/l10n/strings.dart`, `lib/services/auth_service.dart`, `lib/utils/format.dart`, `test/` (fee_test/seed_test) and `android/app/src/main/AndroidManifest.xml`. (The earlier "Flutter source safe, 61M" check was size-only — the Dart files were already gone; staging was permanently deleted, so no other copy existed.)
- **Fix:** all 11 missing files were recovered from the PC zip `~/workspace/donexia-flutter.zip` (created 13 Nov 05:51 IST, before the cleanup) and restored into the workspace — verified byte-identical to the zip for all surviving files. Local `flutter analyze` and `flutter test` (3/3 passed) re-verified on the restored project. Pushed as commit `4284e34d4e3dae10ddc7c45d262a83a3ce1b0186` on main.
- **Run #2 — https://github.com/iamcaravi/Donexia/actions/runs/43459752827 — FAILURE** at step 6 Analyze: only 2 warnings, both `asset_directory_does_not_exist` (`assets/images/`, `assets/icons/` in pubspec.yaml). This Flutter version makes `flutter analyze` exit 1 on warnings (verified locally: real exit code 1, not a pipe artifact). No Dart code references those asset dirs. Fix: created empty `assets/images/` + `assets/icons/` with `.gitkeep`, local analyze now "No issues found!" (exit 0). Pushed as commit `c6c465027910c316e429b32c176c50b7a91a61c7` on main.
- **Run #3 — https://github.com/iamcaravi/Donexia/actions/runs/43461033947 — CANCELLED 13 Nov ~23:22 IST after ~96 min hung on step 8 "Build release APK" (see new section at top for full log diagnosis). No APK.**
- Lesson recorded: after any storage cleanup, verify the Flutter source by FILE INVENTORY (`flutter analyze` on the real tree), not by directory size — 11-Nov-dated lib files were silently gone while the folder still showed 61M.

## 13 Nov 2026 ~17:30 IST — Repo created by user, source PUSHED, workflow file BLOCKED (token lacks Workflows permission), NO APK yet

- Repo: https://github.com/iamcaravi/Donexia (public, created by the user at github.com/new, empty, default branch `main`).
- Push SUCCEEDED via the git-database API: 139 files, commit `e3584aa1fb827f554abaacf4d20af17d12775564` on `main` (verified: ref points at that commit; tree contains `lib/main.dart`, `pubspec.yaml`, `android/`, `ios/`, `web/`, `README.md`). Excluded: `build/`, `.dart_tool/`, `android/.gradle/`, `.idea/`, `*.log`, `*.iml`, generated/ephemeral files.
- Note: the `custom.github` connector helper (`~/workspace/custom-connectors/custom.github/bin/github-api.py`) had been deleted in the 13 Nov storage cleanup; it was recreated from `/opt/muse/skills/custom-connector-setup/bin/dynamic_credentials.py` (credential name `custom.github`) and verified working (`GET /user` → `iamcaravi`). Also: the git-database API refuses blob/tree creation on a completely empty repo (409 "Git Repository is empty"), so the first commit was made via the Contents API (`PUT .../contents/README.md`), then the full push was built on it.
- BLOCKER — workflow file NOT pushed: a tree containing only `.github/workflows/build-apk.yml` returns **403** `Resource not accessible by personal access token`, while a tree of 20 normal files returns 201. Cause: the fine-grained token has Contents + Actions but NOT the separate **Workflows** repository permission, which GitHub requires to create/update workflow files via the API. No workflow run exists yet, so no APK.
- **Next step the user must do:** on the same token edit page (https://github.com/settings/tokens?type=beta → token `muse` → Edit), click **+ Add permissions → Workflows → Read and write**, then click **Update** (do NOT regenerate the token). Then tell Muse to resume: only the single workflow file needs pushing, then dispatch the workflow, poll the run, and download `app-release.apk`.

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
