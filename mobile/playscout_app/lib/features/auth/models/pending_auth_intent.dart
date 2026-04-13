/// Deferred navigation / action after a successful sign-in.
enum PendingAuthIntentKind {
  /// Open the Favorites tab (member-only affordances).
  openFavorites,

  /// Return to a specific route path (e.g. `/venue/xyz`).
  openPath,

  /// After full-member auth, POST favorite for [venueId].
  toggleFavoriteVenue,

  /// After full-member auth, open write review for [venueId].
  writeReviewVenue,

  /// After full-member auth, open suggest-place form.
  suggestPlaceForm,
}

class PendingAuthIntent {
  const PendingAuthIntent._(this.kind, {this.path, this.venueId});

  final PendingAuthIntentKind kind;
  final String? path;
  final String? venueId;

  static const PendingAuthIntent openFavorites =
      PendingAuthIntent._(PendingAuthIntentKind.openFavorites);

  static PendingAuthIntent openPath(String location) {
    return PendingAuthIntent._(PendingAuthIntentKind.openPath, path: location);
  }

  static PendingAuthIntent toggleFavorite(String venueId) {
    return PendingAuthIntent._(PendingAuthIntentKind.toggleFavoriteVenue, venueId: venueId);
  }

  static PendingAuthIntent writeReview(String venueId) {
    return PendingAuthIntent._(PendingAuthIntentKind.writeReviewVenue, venueId: venueId);
  }

  static const PendingAuthIntent suggestPlaceForm =
      PendingAuthIntent._(PendingAuthIntentKind.suggestPlaceForm);

  Map<String, dynamic> toJson() => {
        'k': kind.name,
        if (path != null) 'p': path,
        if (venueId != null) 'v': venueId,
      };

  static PendingAuthIntent? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final k = json['k'] as String?;
    if (k == PendingAuthIntentKind.openFavorites.name) {
      return PendingAuthIntent.openFavorites;
    }
    if (k == PendingAuthIntentKind.openPath.name) {
      final p = json['p'] as String?;
      if (p == null || p.isEmpty) return null;
      return PendingAuthIntent.openPath(p);
    }
    if (k == PendingAuthIntentKind.toggleFavoriteVenue.name) {
      final v = json['v'] as String?;
      if (v == null || v.isEmpty) return null;
      return PendingAuthIntent.toggleFavorite(v);
    }
    if (k == PendingAuthIntentKind.writeReviewVenue.name) {
      final v = json['v'] as String?;
      if (v == null || v.isEmpty) return null;
      return PendingAuthIntent.writeReview(v);
    }
    if (k == PendingAuthIntentKind.suggestPlaceForm.name) {
      return PendingAuthIntent.suggestPlaceForm;
    }
    return null;
  }
}

/// Result of [AuthSession.dispatchPendingIntent].
class PendingIntentDispatch {
  const PendingIntentDispatch({required this.navigated});

  /// `true` when navigation was handled by the intent (e.g. `go`, `push`, `pushReplacement`).
  final bool navigated;
}
