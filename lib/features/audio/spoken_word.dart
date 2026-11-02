/// A complete word or sentence. Syllables and isolated sounds require approved recordings.
abstract interface class SpokenWord {
  String get text;
  String get ttsText;
  String get locale;
  String? get assetPath;
}
