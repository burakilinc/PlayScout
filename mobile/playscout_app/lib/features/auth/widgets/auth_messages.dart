import 'package:playscout_app/l10n/app_localizations.dart';

import '../data/auth_api_repository.dart';

String authErrorMessage(AppLocalizations l10n, Object error) {
  if (error is AuthApiValidationException) {
    return error.combinedMessage();
  }
  if (error is AuthApiUnauthorizedException) {
    return l10n.authErrorInvalidCredentials;
  }
  if (error is AuthApiGoogleNotConfiguredException) {
    return l10n.authErrorGoogleNotConfigured;
  }
  if (error is AuthApiConflictException) {
    return l10n.authErrorEmailLinkedGoogle;
  }
  if (error is AuthApiAppleNotImplementedException) {
    return l10n.authErrorAppleComingSoon;
  }
  if (error is AuthApiHttpException) {
    return error.detail ?? error.title ?? l10n.authErrorGeneric;
  }
  if (error is StateError) {
    if (error.message == 'cancelled') return '';
    if (error.message == 'google_sign_in_unconfigured_web') {
      return l10n.authErrorGoogleWebUnconfigured;
    }
    if (error.message == 'missing_id_token') {
      return l10n.authErrorGoogleIdToken;
    }
    if (error.message == 'missing_identity_token') {
      return l10n.authErrorAppleIdentity;
    }
  }
  if (error is UnsupportedError) {
    return l10n.authErrorAppleUnavailable;
  }
  return l10n.authErrorGeneric;
}

bool authErrorIsSilent(Object error) => error is StateError && error.message == 'cancelled';
