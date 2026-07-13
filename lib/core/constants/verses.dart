import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quranic verses on giving — rotated on the welcome screen.
/// The inbox keeps Saba' 34:39 as the anchor verse.
class Verse {
  final String ar;
  final String fr;
  final String refLatin;

  const Verse({required this.ar, required this.fr, required this.refLatin});
}

const verses = [
  Verse(
    ar: 'وَمَا أَنفَقْتُم مِّن شَيْءٍ فَهُوَ يُخْلِفُهُ',
    fr: '« Tout ce que vous donnez,\nIl le remplace. »',
    refLatin: "SABA'  ·  34:39",
  ),
  Verse(
    ar: 'لَن تَنَالُوا الْبِرَّ حَتَّىٰ تُنفِقُوا مِمَّا تُحِبُّونَ',
    fr: '« Vous n\'atteindrez la vraie piété\nque si vous donnez de ce que vous aimez. »',
    refLatin: 'ĀL ʿIMRĀN  ·  3:92',
  ),
  Verse(
    ar: 'وَمَا تُقَدِّمُوا لِأَنفُسِكُم مِّنْ خَيْرٍ تَجِدُوهُ عِندَ اللَّهِ',
    fr: '« Tout bien que vous avancez pour vous-mêmes,\nvous le retrouverez auprès de Dieu. »',
    refLatin: 'AL-BAQARAH  ·  2:110',
  ),
  Verse(
    ar: 'مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا فَيُضَاعِفَهُ لَهُ',
    fr: '« Quiconque fait à Dieu un beau prêt,\nIl le lui multipliera. »',
    refLatin: 'AL-ḤADĪD  ·  57:11',
  ),
];

/// One verse per app session — a quiet surprise on each visit.
final verseProvider = Provider<Verse>(
  (_) => verses[Random().nextInt(verses.length)],
);
