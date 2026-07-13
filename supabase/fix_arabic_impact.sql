-- Fixes reversed Arabic impact text (caused by copy-pasting Arabic
-- through a terminal that reverses bidi text).
-- Run in Supabase SQL Editor — copy this from the FILE, not from a chat.

update gift_types set impact_ar = 'تكفي عائلة لأسبوع كامل'   where icon = 'food_basket';
update gift_types set impact_ar = 'تجهّز تلميذاً لموسم دراسي' where icon = 'school';
update gift_types set impact_ar = 'تدفئ طفلاً طوال الشتاء'    where icon = 'clothing';
update gift_types set impact_ar = 'علاج شهر كامل لمريض'      where icon = 'medicine';
update gift_types set impact_ar = 'ماء نظيف لعائلة لأسبوع'    where icon = 'water';

-- Verify: readable Arabic, no isolated/backwards letters
select icon, impact_ar, impact_fr from gift_types order by id;
