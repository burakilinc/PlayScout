import 'package:playscout_app/l10n/app_localizations.dart';

import 'models/pending_auth_intent.dart';

/// Headline + supporting copy for [GuestAccessPromptPage] based on resume intent.
({String title, String body}) guestPromptCopyFor(
  PendingAuthIntent? intent,
  AppLocalizations l10n,
) {
  switch (intent?.kind) {
    case PendingAuthIntentKind.toggleFavoriteVenue:
      return (
        title: l10n.guestTitleFavorites,
        body: l10n.guestBodyFavorites,
      );
    case PendingAuthIntentKind.writeReviewVenue:
      return (
        title: l10n.guestTitleWriteReview,
        body: l10n.guestBodyWriteReview,
      );
    case PendingAuthIntentKind.suggestPlaceForm:
      return (
        title: l10n.guestTitleSuggestPlace,
        body: l10n.guestBodySuggestPlace,
      );
    case PendingAuthIntentKind.openFavorites:
      return (
        title: l10n.guestTitleOpenFavorites,
        body: l10n.guestBodyOpenFavorites,
      );
    case PendingAuthIntentKind.openPath:
      return (
        title: l10n.guestTitleContinue,
        body: l10n.guestBodyContinuePath,
      );
    case null:
      return (
        title: l10n.guestTitleContinue,
        body: l10n.guestBodyDefault,
      );
  }
}
