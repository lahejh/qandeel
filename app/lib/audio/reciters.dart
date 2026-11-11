import '../quran/quran.dart';

/// Where recitation files come from, in the order CLAUDE.md §4 requires.
/// On failure the app tries the SAME reciter on the next source.
enum AudioSourceKind {
  /// 1) King Fahd Glorious Qur'an Printing Complex. Its license allows use in
  /// apps, but as of 2026-11-11 its rebuilt website lists recitations as
  /// "coming soon", so no reciter has a Complex URL yet (docs/NEXT-STEPS.md).
  kingFahdComplex,

  /// 2) Islamic Network / alquran.cloud CDN — recitations licensed to them
  /// by the reciters or their estates for free, non-commercial
  /// redistribution. One file per verse; the ETag is the file's MD5.
  islamicNetwork,

  /// 3) mp3quran.net — only after written permission (not used yet).
  mp3Quran,
}

/// One reciter on one source.
class ReciterSource {
  const ReciterSource(this.kind, this.edition, {this.bitrate = 128});

  final AudioSourceKind kind;

  /// The source's own name for this recitation (e.g. "ar.husary").
  final String edition;
  final int bitrate;

  /// Address of one verse's file on this source.
  Uri verseUri(Verse verse) => switch (kind) {
    // Global verse number 1–6236 (Al-Fatiha 1 = 1, An-Nas 6 = 6236).
    AudioSourceKind.islamicNetwork => Uri.parse(
      'https://cdn.islamic.network/quran/audio/$bitrate/$edition/${verse.index + 1}.mp3',
    ),
    AudioSourceKind.kingFahdComplex ||
    AudioSourceKind.mp3Quran => throw UnsupportedError('$kind has no URLs yet'),
  };

  /// Display name of the source, for the on-screen credit.
  String get creditName => switch (kind) {
    AudioSourceKind.kingFahdComplex =>
      'King Fahd Glorious Qur\'an Printing Complex',
    AudioSourceKind.islamicNetwork => 'Islamic Network (alquran.cloud)',
    AudioSourceKind.mp3Quran => 'mp3quran.net',
  };
}

/// A reciter, with the sources that carry the SAME reciter, in order.
class Reciter {
  const Reciter({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.sources,
  });

  /// Stable id, used for settings and the download folder name.
  final String id;
  final String nameArabic;
  final String nameEnglish;

  /// Sources in priority order (CLAUDE.md §4). Never mix reciters here.
  final List<ReciterSource> sources;

  String name(String languageCode) =>
      languageCode == 'ar' ? nameArabic : nameEnglish;
}

/// All reciters offered (Hafs 'an 'Asim, murattal). The default is Al-Husary:
/// slow, very clear tajweed — the usual choice for children and learners
/// (owner decision 2026-11-11). The other three were also recorded by the
/// King Fahd Complex and get it as source 1 when its files return.
class Reciters {
  static const husary = Reciter(
    id: 'husary',
    nameArabic: 'محمود خليل الحصري',
    nameEnglish: 'Mahmoud Khalil Al-Husary',
    sources: [ReciterSource(AudioSourceKind.islamicNetwork, 'ar.husary')],
  );

  static const huthaify = Reciter(
    id: 'huthaify',
    nameArabic: 'علي بن عبدالرحمن الحذيفي',
    nameEnglish: 'Ali Al-Huthaify',
    sources: [ReciterSource(AudioSourceKind.islamicNetwork, 'ar.hudhaify')],
  );

  static const muaiqly = Reciter(
    id: 'muaiqly',
    nameArabic: 'ماهر المعيقلي',
    nameEnglish: 'Maher Al-Muaiqly',
    sources: [ReciterSource(AudioSourceKind.islamicNetwork, 'ar.mahermuaiqly')],
  );

  static const ayyoub = Reciter(
    id: 'ayyoub',
    nameArabic: 'محمد أيوب',
    nameEnglish: 'Muhammad Ayyoub',
    sources: [
      ReciterSource(AudioSourceKind.islamicNetwork, 'ar.muhammadayyoub'),
    ],
  );

  static const all = [husary, huthaify, muaiqly, ayyoub];
  static const defaultReciter = husary;

  static Reciter byId(String? id) =>
      all.where((r) => r.id == id).firstOrNull ?? defaultReciter;
}
