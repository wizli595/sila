# Sila (صِلة) — "Connection"

A quiet, ad-free mobile app that turns small acts of generosity into real bonds.

## What is Sila?

You create an account, choose a type of gift, and we handle the price, the quantity, and the delivery to someone who needs it. When the gift is received, a photo and a thank-you note arrive in your inbox, closing the loop.

**Tagline:** Give. Wait. Connect.

## Architecture

- **Flutter** mobile app with **clean architecture** (domain → data → presentation)
- **Riverpod** for state management
- **GoRouter** for navigation (6 screens, fade transitions)
- **Supabase** for backend (auth, database, storage, realtime)
- **FCM** for push notifications (only: "Your gift arrived")
- **Lottie** for mascot animations, **Rive** for the thread
- **fpdart** `Either` type for error handling — no silent failures

## Folder Structure

```
lib/
├── main.dart / bootstrap.dart / app.dart
├── core/          → shared: theme, router, error, logger, l10n, constants
└── features/      → one folder per feature, each with data/domain/presentation
    ├── welcome/   → verse + mascot + "Begin"
    ├── auth/      → sign up / sign in
    ├── gifts/     → choose gift type
    ├── payment/   → confirm + pay (card or CashPlus)
    ├── waiting/   → thread animation, "your gift is on its way"
    └── inbox/     → photo + thank-you note from recipient
```

## Design

- **Palette:** warm cream `#FFF8F0`, watermelon `#E8636A`, mango `#F5B041`, iris `#7C83BC`
- **Font:** Cairo (Arabic-first, works for French too)
- **Grid:** 4px spacing system
- **Motif:** a thread (iris-colored) that connects giver to receiver across the app
- **Mascot:** friendly round character — waves on welcome, nods on confirm, holds thread on waiting, steps aside on inbox
- **Verse:** "وَمَا أَنفَقْتُم مِّن شَيْءٍ فَهُوَ يُخْلِفُهُ" (Saba' 34:39) — on welcome + inbox screens

## Languages

- Arabic (primary, RTL) + French (LTR)
- ARB files in `lib/core/l10n/`

## Backend (Supabase)

- **Tables:** profiles, gift_types, gifts, connections
- **Storage:** thank-you-photos bucket
- **RLS:** users see only their own data, admin sees everything
- **Admin role:** managed via `profiles.role` enum ('user' | 'admin')

## Payment

- Card (Stripe or CMI gateway)
- CashPlus (generate payment code, user pays at any point)
- Currency: MAD (Moroccan Dirham), stored in centimes

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
flutter test             # run tests
```
