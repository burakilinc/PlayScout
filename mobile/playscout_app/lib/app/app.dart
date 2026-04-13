import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../design_system/app_theme.dart';
import '../features/auth/auth_session.dart';
import '../features/favorites/favorites_store.dart';
import 'app_criteria_controller.dart';
import 'app_criteria_scope.dart';
import 'auth_scope.dart';
import 'favorites_scope.dart';
import 'locale_controller.dart';
import 'locale_scope.dart';
import 'member_api_scope.dart';
import '../features/suggestions/data/suggestions_repository.dart';
import '../features/venue_detail/data/reviews_write_repository.dart';

class PlayScoutApp extends StatefulWidget {
  const PlayScoutApp({
    super.key,
    required this.router,
    required this.authSession,
    required this.favoritesStore,
    required this.reviewsWriteRepository,
    required this.suggestionsRepository,
    required this.localeController,
  });

  final GoRouter router;
  final AuthSession authSession;
  final FavoritesStore favoritesStore;
  final ReviewsWriteRepository reviewsWriteRepository;
  final SuggestionsRepository suggestionsRepository;
  final LocaleController localeController;

  @override
  State<PlayScoutApp> createState() => _PlayScoutAppState();
}

class _PlayScoutAppState extends State<PlayScoutApp> {
  late final AppCriteriaController _appCriteria = AppCriteriaController();

  @override
  Widget build(BuildContext context) {
    return AppCriteriaScope(
      appCriteria: _appCriteria,
      child: AuthScope(
        authSession: widget.authSession,
        child: FavoritesScope(
          store: widget.favoritesStore,
          child: LocaleScope(
            controller: widget.localeController,
            child: MemberApiScope(
              reviewsWrite: widget.reviewsWriteRepository,
              suggestions: widget.suggestionsRepository,
              child: ListenableBuilder(
                listenable: widget.localeController,
                builder: (context, _) => MaterialApp.router(
                  onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: PsTheme.light(),
                  routerConfig: widget.router,
                  locale: widget.localeController.locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('tr'),
                    Locale('ja'),
                    Locale.fromSubtags(languageCode: 'zh'),
                    Locale('de'),
                    Locale('fr'),
                    Locale('ko'),
                    Locale('pt'),
                    Locale('es'),
                    Locale('ru'),
                    Locale('ar'),
                    Locale('hi'),
                    Locale('it'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
