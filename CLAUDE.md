# Sila (صِلة) — "Connection"

A quiet, ad-free mobile app that turns small acts of generosity into real bonds.

## What is Sila?

You browse gift types freely, pick one, choose an amount (a sensible default is pre-selected), and we handle delivery to someone who needs it. An account is asked for only at the moment of paying. When the gift is received, a photo and a thank-you note arrive in your inbox, closing the loop.

**Tagline:** Give. Wait. Connect.

## Status

Phases 1–6 done: full user app (27 screens), admin panel, mock payments, compliance pages, CI.
Blocked on external accounts: real payment gateways (Stripe/CMI/CashPlus), FCM push (Firebase),
signed iOS builds (Apple Developer). Mascot (Lottie) and Rive thread need designed assets.
See `TODO.md` for the phase-by-phase list.

## Architecture

- **Flutter** mobile app with **clean architecture** (domain → data → presentation)
- **Riverpod** for state management (StateNotifier pattern)
- **GoRouter** — single router instance refreshed via `refreshListenable` (never recreated; that
  resets navigation). IMPORTANT: redirect only re-evaluates the *declarative* location — screens
  pushed with `pushNamed` must navigate away **explicitly** on auth changes (see auth/settings screens)
- **Supabase** for backend (auth, database, storage, realtime) — profile auto-created by DB trigger
- **fpdart** `Either` type for error handling — no silent failures
- **Admin panel** = same repo, separate entrypoint: `flutter run -t lib/main_admin.dart -d chrome`
- **CI:** `codemagic.yaml` — `ios-unsigned` (IPA, no Apple account) + `ios-testflight` (needs setup).
  `pubspec.lock` is committed so CI resolves the exact local package versions

## Folder Structure

```
lib/
├── main.dart / main_admin.dart / bootstrap.dart / app.dart
├── admin/             → admin web panel (login, dashboard, gift-type CRUD, deliveries)
├── core/
│   ├── constants/     → app + supabase constants, gift icons, Quran verses (rotation)
│   ├── error/         → typed failures, exceptions, error handler
│   ├── logger/        → debug logging (logDebug, logInfo, logError)
│   ├── network/       → connectivity check
│   ├── providers/     → shared prefs (locale, one-time flags), app_config (min version)
│   ├── router/        → GoRouter: 22 routes, redirect (locale → update-gate → intro → auth)
│   ├── theme/         → AA palette, Cairo+Amiri typography, warm shadows/glow
│   ├── l10n/          → Arabic + French ARB files (generated)
│   ├── utils/         → validators (email, password, name sanitization)
│   └── widgets/       → SilaThread, ThreadLoading, StaggeredItem, PressScale,
│                        GradientButton (hero CTA only), coachMark, ErrorRetry, ShimmerBox
└── features/
    ├── onboarding/    → language picker, splash, 3-page intro, notify-prime, update-required
    ├── welcome/       → rotating verse + ambient thread + "Begin" (→ browse as guest)
    ├── auth/          → sign in/up, forgot/reset password (deep link sila://auth-callback),
    │                    check-email; navigates home EXPLICITLY on success (pushed-screen rule)
    ├── gifts/         → gift list (guest browsable, pull-to-refresh), my-threads history
    ├── payment/       → confirm (amount chips 50/100/custom, anonymous toggle, impact line)
    │                    + MOCK card & CashPlus screens (real gateways slot in here)
    ├── waiting/       → thank-you + journey thread + latest gift status
    ├── inbox/         → realtime connections list, connection detail (photo + note)
    └── settings/      → profile, language, notifications, password, about (+transparency),
                         privacy, terms, sign out, delete account (delete_user RPC)
```

## Supabase

- **Project:** ijsdjrgqiljovygtnbbu
- **Tables:** profiles, gift_types (+impact_ar/fr), gifts (+is_anonymous, chosen amount),
  connections, app_config (min_version force-update gate)
- **Functions/triggers:** `is_admin()`, `handle_new_user()` (profile on signup), `delete_user()` (self-service)
- **Storage:** thank-you-photos bucket (public read, admin write)
- **Realtime:** connections table in `supabase_realtime` publication (live inbox)
- **RLS:** users see own data only; admin via `is_admin()`
- **SQL:** `supabase/setup.sql` (full), `fix_arabic_impact.sql` (bidi repair, idempotent)
- **Dashboard config:** email confirmation OFF for now (re-enable pre-launch — check-email
  screen is ready); `sila://auth-callback` must be in Auth → Redirect URLs

## Design

- **Palette:** warm cream `#FFF8F0`, watermelon `#E8636A`, mango `#F5B041`, iris `#7C83BC` (decorative) + deep AA variants for text/buttons (`watermelonDeep #C7414A`, `irisDeep #5A628F`, ink `#33302B`, taupe `#75695C`) — full table in `DESIGN.md`
- **Fonts:** Cairo (UI, Arabic-first, body line-height 1.65) + Amiri (Quranic verse, naskh)
- **Depth & motion:** warm card shadows, glow on primary buttons, ONE gradient (hero CTA),
  staggered list entrances, hero gift icon (list → confirm), haptics, thread-based loaders
- **Thread:** 3 modes — ambient (welcome/loading), journey (waiting), tied (inbox);
  RTL-aware (draws right-to-left in Arabic); respects reduced motion
- **Verses:** rotate per visit on welcome (`core/constants/verses.dart`); inbox keeps Saba' 34:39
- **Coach marks:** one-time tours (home nav, confirm, waiting, inbox) — must only start when
  their screen is the visible route (`ModalRoute.isCurrent`)

## Security

- Input validation before any Supabase call (validators.dart)
- Email normalized to lowercase, control characters stripped
- Password min 8, max 128 chars; account deletion re-authenticates first
- Session auto-refresh with expiry check
- RLS on all tables — no client-side trust; admin actions gated by `is_admin()` server-side
- Anonymous gifts: name hidden in admin UI (DB keeps giver_id for RLS/inbox)

## Languages & RTL

- Arabic (primary, RTL) + French (LTR); runtime switch in settings, first-launch picker
- ARB files in `lib/core/l10n/` → `flutter gen-l10n` (runs automatically on build)
- Latin-content inputs (email/password/card) force `TextDirection.ltr`
- **Arabic data must travel in logical order** — never copy Arabic through chat/terminal
  (clipboard reverses bidi → broken data). Type in the admin panel or copy from files.

## Payment

- Currency: MAD, stored in centimes; user picks amount (gift default pre-selected, 50/100/custom)
- Mock card + CashPlus screens are demo-marked; real Stripe/CMI/CashPlus replace only the
  simulated part inside `pay_card_screen.dart` / `pay_cash_screen.dart`
- Gifts stay `pending` until admin marks paid (manual verification model)

## Compliance

- `docs/` = GitHub Pages (enable: Settings → Pages → master /docs): landing, privacy, terms,
  delete-account — the URLs for Play Console Data Safety / App Store

## Rules

- **Git:** NEVER add `Co-Authored-By`, `Claude-Session`, or any AI attribution to commits or PRs. Plain conventional commits only (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
- **Clean code:** no dead code, no duplicated constants/maps, small focused files, no enterprise boilerplate or speculative abstraction. Delete unused providers/deps instead of keeping them "just in case".
- **Best practices:** `const` constructors wherever possible; every repository method returns `Either<Failure, T>`; dispose all controllers; validate/sanitize input before any Supabase call; never trust the client — RLS is the security boundary.
- **Design:** text contrast ≥ 4.5:1 (AA) — functional colors live in `AppColors` deep variants, decorative colors (thread, tints) may be softer; touch targets ≥ 44px; animations 150–400ms, respect `MediaQuery.disableAnimations`. See `DESIGN.md`.
- **Navigation:** login/logout/delete always land on home; pushed screens navigate explicitly
  (router redirect can't see them); `go` replaces history, `push` layers — back must always work.

## Key Principles

- Amount is a quiet choice — the gift's default is pre-selected; giving works without thinking about money
- One gift at a time — no bulk orders
- Anonymous giving is one toggle away, respected everywhere
- The thank-you is not instant — the wait is intentional
- No feed, no leaderboard, no streaks — inbox is private
- Notifications: only "your connection arrived" — nothing else
- Browse first: no account until the moment of paying
- Clean code: minimal, no over-abstraction, no enterprise boilerplate

## Commands

```bash
flutter pub get                                      # install dependencies
flutter gen-l10n                                     # regenerate translations
flutter analyze                                      # must be clean before commit
flutter run -d emulator-5554                         # user app on Android emulator
flutter run -t lib/main_admin.dart -d chrome         # admin panel (or -d web-server --web-port 8322)
flutter test                                         # run tests
adb shell pm clear com.sila.sila                     # reset to first-run state (Android)
```

## Git

- Repo: https://github.com/wizli595/sila
- Branch: master
