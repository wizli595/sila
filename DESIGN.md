# Sila Design System

Warm, quiet, human. The design direction is **"nature distilled"**: cream surfaces, soft organic
shapes, one thread of color running through everything. No noise, no gamification, no urgency.

## Palette

Decorative colors carry the brand; deep variants carry information. Never use a decorative color
for text on cream/white.

| Token | Hex | Role | Contrast on cream |
|---|---|---|---|
| `cream` | `#FFF8F0` | Background | — |
| `watermelon` | `#E8636A` | Decorative — thread, dots | 3.3:1 (decorative only) |
| `watermelonDeep` | `#C7414A` | Filled buttons (white text) | 4.9:1 w/ white ✓ AA |
| `mango` | `#F5B041` | Decorative — icon tints at 15% alpha | 1.8:1 (decorative only) |
| `iris` | `#7C83BC` | Decorative — thread, focus border | 3.4:1 (decorative only) |
| `irisDeep` | `#5A628F` | Interactive text, links | 5.6:1 ✓ AA |
| `charcoal` | `#33302B` | Primary text (warm ink) | 12.5:1 ✓ AAA |
| `softGray` | `#75695C` | Secondary text (warm taupe) | 5.1:1 ✓ AA |
| `lightGray` | `#F2EDE7` | Borders, card outlines | — |
| `success` | `#6BBF8A` | Success states | — |
| `error` | `#D94F4F` | Errors, destructive | — |

Verify any new pairing with a WCAG check: text ≥ 4.5:1, large text/UI glyphs ≥ 3:1.

## Typography

- **Cairo** — all UI text (Arabic-first variable TTF). Scale: 28/22/18/16/14 with weights 700/600/600/400/400.
- **Amiri** — Quranic verse only (classical naskh, 24px, height 2.0). The verse is sacred text;
  give it breathing room and never restyle it with UI weights.

## Depth (2026 research: depth is information, not decoration)

- Cards float on a **soft warm shadow** (`#B5651D` at ~19%, elevation 4) — above the cream, tappable.
- Primary buttons carry a **watermelon glow** (elevation 6, colored shadow) — depth marks the one action that matters.
- The hero CTA ("begin", intro) is the **only gradient** in the app: watermelonDeep → watermelon, start→end (RTL-aware).
- Everything else stays flat — depth is rationed, or it means nothing.

## Motion

- Thread animation: draw 1.5–3s once, breath loop 3s. All other transitions 150–400ms, ease-out in / ease-in out.
- Lists **stagger in** (40ms/item, capped at 10) — flow, not a wall.
- Gift icon is a **Hero** — it flies from the list to the confirm screen for continuity.
- Press feedback: scale 0.97 + `HapticFeedback.selectionClick`; hero CTAs use `lightImpact`.
- Respect `MediaQuery.disableAnimations` — thread renders fully drawn, no loops, no stagger.
- Loading: the thread draws itself — never a spinner.

## Thread modes

- **ambient** — horizontal wave with a loop (welcome, auth), watermelon
- **journey** — vertical, giver dot (iris) → destination dot (mango) (waiting)
- **tied** — two dots joined with a bow + knot (inbox)

## Avoid

- Decorative colors as text (fails contrast)
- Emojis as icons — rounded Material icons only, one style
- Spinners for content loading (use shimmer), animations > 500ms
- Anything loud: badges, streaks, counters, red notification dots
