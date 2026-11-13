# Donexia — A Small Help. A Big Difference.

India-focused social help & donation Android app (Flutter MVP).

> **App name is Donexia, NOT Udaar.** Tagline: "A Small Help. A Big Difference."

- Categories: Loan Relief, Medical Help, Education, Emergency
- Languages: Hindi + English (toggle in Home/Profile)
- Theme: Primary `#168653`, Secondary `#22A06B`, Background `#FFFFFF`, Surface `#F3FAF6`, Text `#202B25`, Error `#DC2626`
- Roles: Donor, Help Seeker, Admin (role-based; admin route guarded)
- Platform fee: **1%** of every donation, shown transparently
- **Demo only: no backend, no real SMS, no real payments.** All data is local (SharedPreferences JSON) and seeded on first launch.

## Screens

Splash → 3 onboarding slides → Mobile + Demo OTP login → Registration (name, optional email, state, district, profile photo optional, terms consent) → Home (greeting, search, 4 categories, Create Campaign, Featured / Recently Added / Most Needed, totals, bottom nav Home / Explore / My Donations / Profile) → Explore (filters All / Loan / Medical / Education / Emergency + state / district / verified / recent / most-needed + search) → Campaign Details → Create Campaign 6-step wizard → Donate → Receipt → My Donations → Admin Panel.

## Campaign creation — 6 steps

1. Category · 2. Personal info · 3. Category form (loan: type, bank/NBFC, outstanding, EMI; medical: disease, hospital; education: school, fees; emergency: type) · 4. Private payment destination (UPI / bank — **never shown publicly**) · 5. Preview / edit · 6. Consent & submit → status `Pending Verification`.

Campaign statuses: Draft / Pending Verification / Approved / Rejected / More Info Required / Active / Completed / Suspended. Only Approved/Active campaigns are public.

## Privacy

Never publicly displayed: loan account numbers, bank account numbers, Aadhaar, PAN, private medical reports or confidential documents. Payment details live only in the private step-4 form and admin verification.

## Demo credentials

| Account | Phone | OTP |
|---|---|---|
| Demo user (any 10-digit number) | e.g. `9876543210` | `123456` |
| **Demo admin** | `9999999999` | `123456` |

The demo OTP `123456` is shown on the login screen itself — no SMS is sent. Admin login opens the Admin Panel (approve / reject with reason, request documents, banks/NBFC master list, transactions, analytics).

## Demo data

10 seeded campaigns (Kanpur, Lucknow, Varanasi, Agra, Gorakhpur, Prayagraj, Jhansi), including the spec example: **Rahul Kumar, Kanpur — SBI personal loan ₹2,40,000, ₹1,29,600 raised (54%), 214 donors**. Reset from Profile → Reset demo data.

Banks/NBFCs (17): SBI, PNB, Bank of Baroda, Canara Bank, Union Bank, Bank of India, Indian Bank, HDFC Bank, ICICI Bank, Axis Bank, Kotak Mahindra Bank, Bajaj Finance, Tata Capital, Shriram Finance, Muthoot Finance, Manappuram Finance, Other. Admin can add / deactivate them.

## Build the APK (exact steps)

Prerequisites: Flutter SDK 3.22+ installed and on PATH, Android SDK + an Android device/emulator or a connected phone for `flutter run`.

```bash
cd ~/workspace/donexia-flutter
flutter pub get
flutter analyze        # optional static check
flutter test           # optional: 1% fee + seed-data tests
flutter build apk --release
```

The release APK lands at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Install it with `flutter install` or `adb install build/app/outputs/flutter-apk/app-release.apk`.

For a quick run without building:

```bash
flutter run
```

## Project structure

```
lib/
  main.dart                 # routes + admin route guard
  models/  campaign.dart  user.dart  bank.dart
  data/    seed_data.dart (10 campaigns)  local_store.dart (SharedPreferences)
  services/  app_state.dart (Provider)  auth_service.dart (demo OTP)
  screens/  splash, onboarding, auth, register, home, explore,
            campaign_detail, create_campaign, donate, my_donations,
            profile, admin
  widgets/  campaign_card.dart (card + category chips)
            progress_bar.dart (progress bar + DemoBanner)
  l10n/     strings.dart (hi/en)
  utils/    theme.dart  format.dart
test/  fee_test.dart  seed_test.dart
```

## What is NOT in this build

- No backend / API, no real OTP/SMS provider, no real payment gateway (UPI/QR/Card/Net Banking are simulated).
- **No APK yet (13 Nov 2026):** `flutter analyze` is clean and `flutter test` passes 3/3, but `flutter build apk` cannot run on this VM — the sandbox blocks JVM TCP connections (`other_tcp` = Deny), which Gradle's daemon needs. Fix: in Muse settings → Permissions → Direct network protocols, switch `other_tcp` from Deny to Ask, then rerun `flutter build apk --release` (with `GRADLE_USER_HOME=/home/hatch/.gradle`). Full details in `BUILD_REPORT.md`.
- Image URLs in seed data are `picsum.photos` placeholders; replace with real beneficiary photos (with consent) before any public release.
