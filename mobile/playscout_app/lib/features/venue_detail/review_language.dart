/// Mirrors server [LanguageCodes] supported primaries for `originalLanguage`.
bool isSupportedReviewLanguage(String normalizedPrimary) =>
    _supported.contains(normalizedPrimary);

/// Returns primary subtag lowercased, or null if invalid.
String? normalizeReviewLanguageTag(String? input) {
  if (input == null) return null;
  final t = input.trim();
  if (t.isEmpty) return null;
  final sep = t.indexOf(RegExp(r'[-_]'));
  final primary = sep < 0 ? t : t.substring(0, sep);
  if (primary.length < 2 || primary.length > 8) return null;
  for (final c in primary.runes) {
    if (!((c >= 65 && c <= 90) || (c >= 97 && c <= 122))) {
      return null;
    }
  }
  return primary.toLowerCase();
}

const _supported = <String>{
  'en', 'tr', 'de', 'fr', 'es', 'it', 'pt', 'nl', 'pl', 'ru', 'ar', 'ja', 'ko', 'zh',
  'hi', 'sv', 'da', 'fi', 'no', 'nb', 'nn', 'cs', 'sk', 'hu', 'ro', 'bg', 'el', 'he',
  'id', 'ms', 'th', 'vi', 'uk', 'sl', 'hr', 'sr', 'lt', 'lv', 'et', 'is', 'ga', 'mt',
};
