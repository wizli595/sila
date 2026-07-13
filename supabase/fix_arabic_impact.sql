-- Repairs reversed Arabic impact text (clipboard bidi mangling).
-- Pure ASCII — safe to copy from anywhere, safe to run multiple times.
--
-- The stored strings are exactly character-reversed, so reverse() restores
-- them. The WHERE clause checks the first letter's code point against the
-- correct value, so already-fixed rows are left untouched:
--   food_basket/school/clothing start with U+062A (teh)
--   medicine starts with U+0639 (ain), water with U+0645 (meem)

update gift_types
set impact_ar = reverse(impact_ar)
where (icon in ('food_basket', 'school', 'clothing') and ascii(impact_ar) <> 1578)
   or (icon = 'medicine' and ascii(impact_ar) <> 1593)
   or (icon = 'water'    and ascii(impact_ar) <> 1605);

-- Verify: Arabic should read naturally, letters connected
select icon, impact_ar from gift_types order by id;
