/// Normalizes venue ids for favorites API + in-memory index (GUID strings).
abstract final class FavoriteVenueIds {
  static String canonical(String raw) {
    var s = raw.trim();
    if (s.length >= 32 && s.startsWith('{') && s.endsWith('}')) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s.toLowerCase();
  }
}
