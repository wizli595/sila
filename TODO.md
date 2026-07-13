# Sila — TODO

## Phase 1: Foundation ✅

- [x] Flutter project setup + folder structure
- [x] Theme (colors, typography, spacing)
- [x] GoRouter with 6 screens
- [x] Localization (Arabic + French ARB files)
- [x] Error handling (typed failures, Either pattern)
- [x] Logger + network checker
- [x] Domain entities (User, GiftType, Gift, Connection)
- [x] Repository contracts (Auth, Gift, Inbox)
- [x] Screen stubs with navigation flow
- [x] Thread animation placeholder (CustomPainter)

## Phase 2: Auth & Backend ✅

- [x] Set up Supabase project (tables, RLS policies, storage bucket)
- [x] Download + bundle Cairo font (variable TTF)
- [x] Implement AuthRepository with Supabase (sign up, sign in, sign out)
- [x] Auth state management with Riverpod (AuthNotifier + AuthState)
- [x] Profile creation on sign up (profiles table)
- [x] Protected routes — route guard redirects unauthenticated users
- [x] Session persistence (Supabase auto-refresh)
- [x] Input validation + sanitization (email, password, name)
- [x] Thread animation system — 3 modes (ambient, journey, tied)
- [x] Supabase SQL setup file (supabase/setup.sql)

## Phase 3: Gift Flow ✅ (payment deferred)

- [x] Fetch gift types from Supabase (GiftRepository implementation)
- [x] Gift type cards with real data (icons, bilingual names)
- [x] Create gift record on confirm
- [ ] Payment integration — card (Stripe or CMI) ← BLOCKED: needs merchant account + keys
- [ ] Payment integration — CashPlus (generate code, verify payment) ← BLOCKED: needs CashPlus account
- [x] Admin can mark gift as paid manually (cash verification, admin panel)
- [x] Navigate to waiting screen after confirm (shows latest gift + status)

## Phase 4: The Connection (Inbox) ✅ (FCM deferred)

- [x] Fetch user's connections from Supabase
- [x] Display thank-you photo + note in inbox
- [x] Realtime listener — connections stream updates the inbox live
- [ ] Push notification via FCM ("صِلتك وصلت") ← BLOCKED: needs Firebase project config
- [x] Connection card design (photo, note, date, thread tied)
- [x] Empty state → first gift prompt

## Phase 5: Animations & Polish

- [ ] Design mascot in Lottie (wave, nod, hold thread, step aside) ← needs designed asset
- [ ] Design thread in Rive (interactive, state machine) ← needs designed asset
- [x] Thread running subtly across screen edges (ambient mode)
- [x] Waiting screen: thread extends with gentle pulse (journey mode)
- [x] Inbox screen: thread ties animation (tied mode)
- [x] Reduced motion support (thread + shimmer respect disableAnimations)
- [ ] Welcome screen: mascot entrance animation
- [x] Gift cards: soft press/select animation (PressScale, 0.97)
- [x] Page transitions: smooth fade between all 6 screens
- [x] Loading states: shimmer placeholders (not spinners)
- [x] Design pass — WCAG AA palette + Amiri verse font (see DESIGN.md)

## Phase 6: Admin Panel (Flutter Web) ✅

- [x] Separate entrypoint `lib/main_admin.dart` (run: `flutter run -t lib/main_admin.dart -d chrome`)
- [x] Admin auth (check role = 'admin', non-admins rejected)
- [x] Dashboard — overview: pending / paid / delivered / connections
- [x] Gift type management — CRUD (add, edit, toggle active, set price)
- [x] Delivery flow — mark paid (manual verification), mark as delivered
- [x] Upload thank-you photo + write note (Arabic + French)
- [ ] Connection created → triggers push to giver ← BLOCKED: needs FCM setup

## Phase 6.5: All Screens ✅

- [x] Language picker (first launch, bilingual, persisted)
- [x] Splash screen with thread animation (while session resolves)
- [x] "How it works" page (Give. Wait. Connect.)
- [x] Forgot password + reset password (deep link `sila://auth-callback`)
- [x] "Check your email" screen (for when confirmation is re-enabled)
- [x] My Threads — gift history with statuses
- [x] Connection detail — full photo + note + tied thread
- [x] Settings hub (profile, language, notifications, about, privacy)
- [x] Edit name, change password
- [x] Sign out (with confirm)
- [x] Delete account (re-auth + server-side `delete_user()` RPC)
- [x] Navigation from gifts screen (settings / inbox / history icons)
- [x] Thread-based loading states everywhere
- [x] Profile auto-creation trigger on sign-up (works with email confirmation)

## Phase 7: Pre-Launch

- [ ] App icon + native splash (cream background, Sila logo)
- [ ] Error screens (no internet, server error, payment failed)
- [ ] Accessibility pass (screen reader, contrast, touch targets)
- [ ] RTL testing across all screens
- [ ] Performance pass (image caching, lazy loading)
- [ ] Real privacy policy + terms text (placeholder in app now)
- [ ] Re-enable email confirmation (check-email screen is ready)
- [ ] Firebase project setup (FCM, crashlytics)

## Phase 8: Launch

- [ ] Android build + Play Store listing
- [ ] iOS build + App Store listing
- [ ] Landing page (simple, the verse, download links)
- [ ] First batch of gift types configured by admin
- [ ] First test delivery cycle end-to-end
- [ ] Soft launch with small group

---

## Ideas (Later)

- [ ] Gift history — "My Threads" screen showing past connections
- [ ] Seasonal gifts — Ramadan, Eid, back-to-school specials
- [ ] Share a connection — generate a beautiful card image from your thank-you
- [ ] Multiple languages — add Amazigh, English
- [ ] Recurring gifts — monthly giving option
- [ ] Impact counter — total gifts given (community-wide, not per-user)
- [ ] Verse rotation — different verse on each visit (optional)
- [ ] Dark mode (warm dark, not pure black)
