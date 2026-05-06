# Sila — TODO

## Phase 1: Foundation (Current)

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

## Phase 2: Auth & Backend

- [ ] Set up Supabase project (create tables, RLS policies, storage bucket)
- [ ] Download + bundle Cairo font files
- [ ] Implement AuthRepository with Supabase (sign up, sign in, sign out)
- [ ] Auth state management with Riverpod (auth provider, redirect guard)
- [ ] Profile creation on sign up (profiles table)
- [ ] Protected routes — redirect to auth if not logged in
- [ ] Session persistence (stay logged in between launches)

## Phase 3: Gift Flow

- [ ] Fetch gift types from Supabase (GiftRepository implementation)
- [ ] Gift type cards with real data (icons, bilingual names)
- [ ] Create gift record on confirm
- [ ] Payment integration — card (Stripe or CMI)
- [ ] Payment integration — CashPlus (generate code, verify payment)
- [ ] Update gift status on payment success
- [ ] Navigate to waiting screen after payment

## Phase 4: The Connection (Inbox)

- [ ] Fetch user's connections from Supabase
- [ ] Display thank-you photo + note in inbox
- [ ] Realtime listener — new connection triggers notification
- [ ] Push notification via FCM ("صِلتك وصلت")
- [ ] Connection card design (photo, note, date, thread tied)
- [ ] Empty state → first gift prompt

## Phase 5: Animations & Polish

- [ ] Design mascot in Lottie (wave, nod, hold thread, step aside)
- [ ] Design thread in Rive (interactive, state machine)
- [ ] Thread running subtly across screen edges during navigation
- [ ] Welcome screen: mascot entrance animation
- [ ] Waiting screen: thread extends with gentle pulse
- [ ] Inbox screen: thread ties animation when connection loads
- [ ] Gift cards: soft press/select animation
- [ ] Page transitions: smooth fade between all 6 screens
- [ ] Loading states: shimmer placeholders (not spinners)

## Phase 6: Admin Panel (Flutter Web)

- [ ] Separate Flutter Web target in `admin/`
- [ ] Admin auth (check role = 'admin')
- [ ] Dashboard — overview: pending gifts, delivered, stats
- [ ] Gift type management — CRUD (add, edit, toggle active, set price)
- [ ] Delivery flow — see paid gifts, mark as delivered
- [ ] Upload thank-you photo + write note (Arabic + French)
- [ ] Connection created → triggers push to giver

## Phase 7: Pre-Launch

- [ ] App icon + splash screen (cream background, Sila logo)
- [ ] Onboarding — first-time language picker (Arabic / French)
- [ ] Error screens (no internet, server error, payment failed)
- [ ] Accessibility pass (screen reader, contrast, touch targets)
- [ ] RTL testing across all screens
- [ ] Performance pass (image caching, lazy loading)
- [ ] Privacy policy + terms (required for app stores)
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
