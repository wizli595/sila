# Sila (صِلة) — "Connection"

A quiet, ad-free mobile app that turns small acts of generosity into real bonds.

## What is Sila?

You create an account, choose a type of gift, and we handle the price, the quantity, and the delivery to someone who needs it. When the gift is received, a photo and a thank-you note arrive in your inbox, closing the loop.

**Tagline:** Give. Wait. Connect.

## Architecture

- **Flutter** mobile app with **clean architecture** (domain → data → presentation)
- **Riverpod** for state management (StateNotifier pattern)
- **GoRouter** for navigation (6 screens, fade transitions, auth guard)
- **Supabase** for backend (auth, database, storage, realtime)
- **FCM** for push notifications (only: "Your gift arrived")
- **Lottie** for mascot animations (TODO), **CustomPainter** for the thread
- **fpdart** `Either` type for error handling — no silent failures

## Folder Structure

```
lib/
├── main.dart / bootstrap.dart / app.dart
├── core/
│   ├── constants/     → app + supabase constants
│   ├── error/         → typed failures, exceptions, error handler
│   ├── logger/        → debug logging (logDebug, logInfo, logError)
│   ├── network/       → connectivity check
│   ├── router/        → GoRouter with auth guard
│   ├── theme/         → colors, typography, spacing, full theme
│   ├── l10n/          → Arabic + French ARB files (generated)
│   ├── utils/         → validators (email, password, name sanitization)
│   └── widgets/       → SilaThread (ambient/journey/tied modes)
└── features/
    ├── welcome/       → verse + mascot + ambient thread + "Begin"
    ├── auth/          → sign up/in with validation, Supabase auth
    │   ├── data/      → UserModel, AuthRepositoryImpl
    │   ├── domain/    → SilaUser entity, AuthRepository contract
    │   └── presentation/ → AuthNotifier/AuthState provider, auth screen
    ├── gifts/         → choose gift type (data from Supabase)
    ├── payment/       → confirm + pay (card or CashPlus)
    ├── waiting/       → journey thread animation
    └── inbox/         → tied thread + photo + thank-you note
```

## Supabase

- **Project:** ijsdjrgqiljovygtnbbu
- **Tables:** profiles, gift_types, gifts, connections
- **Storage:** thank-you-photos bucket (public read, admin write)
- **RLS:** users see own data only, `is_admin()` function for admin access
- **Admin role:** `profiles.role` enum ('user' | 'admin')
- **SQL setup:** `supabase/setup.sql`

## Design

- **Palette:** warm cream `#FFF8F0`, watermelon `#E8636A`, mango `#F5B041`, iris `#7C83BC` (decorative) + deep AA variants for text/buttons (`watermelonDeep #C7414A`, `irisDeep #5A628F`, ink `#33302B`, taupe `#75695C`) — full table in `DESIGN.md`
- **Fonts:** Cairo (UI, variable TTF, Arabic-first) + Amiri (Quranic verse, naskh)
- **Grid:** 4px spacing system
- **Thread:** iris-colored, 3 modes — ambient (welcome), journey (waiting), tied (inbox)
- **Mascot:** friendly round character (TODO: Lottie animations)
- **Verse:** "وَمَا أَنفَقْتُم مِّن شَيْءٍ فَهُوَ يُخْلِفُهُ" (Saba' 34:39) — welcome + inbox

## Security

- Input validation before any Supabase call (validators.dart)
- Email normalized to lowercase, control characters stripped
- Password min 8, max 128 chars
- Session auto-refresh with expiry check
- Route guard: unauthenticated → /auth, authenticated skips welcome
- RLS on all tables — no client-side trust
- Admin actions server-side only (is_admin() SQL function)

## Languages

- Arabic (primary, RTL) + French (LTR)
- ARB files in `lib/core/l10n/` → auto-generated via `flutter gen-l10n`

## Payment

- Card (Stripe or CMI gateway)
- CashPlus (generate payment code, user pays at any point)
- Currency: MAD (Moroccan Dirham), stored in centimes

## Rules

- **Git:** NEVER add `Co-Authored-By`, `Claude-Session`, or any AI attribution to commits or PRs. Plain conventional commits only (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
- **Clean code:** no dead code, no duplicated constants/maps, small focused files, no enterprise boilerplate or speculative abstraction. Delete unused providers/deps instead of keeping them "just in case".
- **Best practices:** `const` constructors wherever possible; every repository method returns `Either<Failure, T>`; dispose all controllers; validate/sanitize input before any Supabase call; never trust the client — RLS is the security boundary.
- **Design:** text contrast ≥ 4.5:1 (AA) — functional colors live in `AppColors` deep variants, decorative colors (thread, tints) may be softer; touch targets ≥ 44px; animations 150–400ms, respect `MediaQuery.disableAnimations`. See `DESIGN.md`.

## Key Principles

- No price shown by default — user picks what to give, not how much
- One gift at a time — no bulk orders
- The thank-you is not instant — the wait is intentional
- No feed, no leaderboard, no streaks — inbox is private
- Notifications: only "your connection arrived" — nothing else
- Clean code: minimal, no over-abstraction, no enterprise boilerplate

## Commands

```bash
flutter pub get          # install dependencies
flutter gen-l10n         # regenerate translations
flutter analyze          # check for errors
flutter run              # run on connected device
flutter run -d chrome    # run on Chrome
flutter test             # run tests
```

## Git

- Repo: https://github.com/wizli595/sila
- Branch: master
