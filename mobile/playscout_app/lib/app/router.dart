import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'play_scout_route_observer.dart';

import '../features/auth/auth_session.dart';
import '../features/auth/account_screen.dart';
import '../features/auth/create_account_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/guest_access_prompt_page.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/models/pending_auth_intent.dart';
import '../features/auth/welcome_screen.dart';
import '../features/favorites/favorites_screen.dart';
import 'placeholder_screen.dart';
import 'play_scout_shell.dart';
import '../features/home_discover/home_discover_screen.dart';
import '../features/home_discover/models/venue_summary.dart';
import '../features/interactive_map/interactive_park_map_list_screen.dart';
import '../features/interactive_map/interactive_park_map_screen.dart';
import '../features/filter_options/filter_options_screen.dart';
import '../features/filter_options/models/venue_nearby_criteria.dart';
import '../features/search/models/search_flow_args.dart';
import '../features/search/search_empty_screen.dart';
import '../features/search/search_experience_screen.dart';
import '../features/search/search_results_screen.dart';
import '../features/suggestions/suggest_entry_screen.dart';
import '../features/suggestions/suggest_form_screen.dart';
import '../features/suggestions/suggest_success_screen.dart';
import '../features/suggestions/models/create_suggestion_result.dart';
import '../features/venue_detail/venue_detail_screen.dart';
import '../features/venue_detail/venue_reviews_list_screen.dart';
import '../features/venue_detail/write_review_screen.dart';
import '../features/events/events_activities_screen.dart';
import '../features/events/events_expanded_list_screen.dart';
import '../features/events/models/events_chip_state.dart';
import '../features/events/models/events_list_args.dart';

/// Route paths align with MVP screen set + Event Detail (no Stitch asset).
abstract final class PsRoutes {
  static const home = '/';
  static const venue = '/venue';
  static const filter = '/filter';
  static const map = '/map';
  static const mapList = '/map/list';
  static const events = '/events';
  static const eventsList = '/events/list';
  static const eventDetail = '/events/detail';
  static const favorites = '/favorites';
  static const authWelcome = '/auth/welcome';
  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authForgot = '/auth/forgot-password';
  static const guestPrompt = '/auth/guest-prompt';
  static const account = '/account';
  static const search = '/search';
  static const searchResults = '/search/results';
  static const searchEmpty = '/search/empty';
  static const reviews = '/reviews';
  static const writeReview = '/reviews/write';
  static const recommendations = '/recommendations';
  static const suggestEntry = '/suggest';
  static const suggestForm = '/suggest/form';
  static const suggestSuccess = '/suggest/success';
}

GoRouter buildPlayScoutRouter(AuthSession authSession) {
  return GoRouter(
    initialLocation: PsRoutes.home,
    refreshListenable: authSession,
    observers: [playScoutRouteObserver],
    routes: [
      ShellRoute(
        builder: (context, state, child) => PlayScoutShell(child: child),
        routes: [
          GoRoute(
            path: PsRoutes.home,
            name: 'home_discover',
            builder: (context, state) => const HomeDiscoverScreen(),
          ),
          GoRoute(
            path: PsRoutes.map,
            name: 'interactive_park_map',
            builder: (context, state) => const InteractiveParkMapScreen(),
          ),
          GoRoute(
            path: PsRoutes.mapList,
            name: 'interactive_park_map_list',
            builder: (context, state) {
              final venues = state.extra is List<VenueSummary>
                  ? state.extra! as List<VenueSummary>
                  : const <VenueSummary>[];
              return InteractiveParkMapListScreen(venues: venues);
            },
          ),
          GoRoute(
            path: PsRoutes.events,
            name: 'events_activities',
            builder: (context, state) => const EventsActivitiesScreen(),
          ),
          GoRoute(
            path: PsRoutes.eventsList,
            name: 'events_expanded_list',
            builder: (context, state) {
              final args = state.extra is EventsListArgs
                  ? state.extra! as EventsListArgs
                  : const EventsListArgs(chips: EventsChipState(), sectionTitle: 'Events');
              return EventsExpandedListScreen(args: args);
            },
          ),
          GoRoute(
            path: PsRoutes.favorites,
            name: 'favorites_screen',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: PsRoutes.account,
            name: 'account_screen',
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '${PsRoutes.venue}/:venueId',
        name: 'venue_detail_little_explorers_hub',
        builder: (context, state) {
          final id = state.pathParameters['venueId'] ?? '';
          return VenueDetailScreen(venueId: id);
        },
      ),
      GoRoute(
        path: PsRoutes.filter,
        name: 'filter_options',
        builder: (context, state) => FilterOptionsScreen(
          initialCriteria: state.extra is VenueNearbyCriteria ? state.extra! as VenueNearbyCriteria : null,
        ),
      ),
      GoRoute(
        path: '${PsRoutes.eventDetail}/:eventId',
        name: 'event_detail',
        builder: (context, state) {
          final id = state.pathParameters['eventId'] ?? '';
          return PlaceholderScreen(
            stitchId: 'event_detail',
            extraLabel:
                'Pattern: events_activities + venue_detail. eventId: $id',
          );
        },
      ),
      GoRoute(
        path: PsRoutes.authWelcome,
        name: 'welcome_to_playscout',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: PsRoutes.authLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: PsRoutes.authRegister,
        name: 'create_account',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: PsRoutes.authForgot,
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: PsRoutes.guestPrompt,
        name: 'guest_access_prompt',
        pageBuilder: (context, state) {
          final intent = state.extra is PendingAuthIntent ? state.extra! as PendingAuthIntent : null;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            name: state.name,
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.transparent,
            child: GuestAccessPromptPage(intent: intent),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: PsRoutes.search,
        name: 'search_experience',
        builder: (context, state) => const SearchExperienceScreen(),
      ),
      GoRoute(
        path: PsRoutes.searchResults,
        name: 'search_results',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is SearchFlowArgs
              ? extra
              : const SearchFlowArgs(query: '');
          return SearchResultsScreen(initialArgs: args);
        },
      ),
      GoRoute(
        path: PsRoutes.searchEmpty,
        name: 'no_results_found',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is SearchFlowArgs
              ? extra
              : const SearchFlowArgs(query: '');
          return SearchEmptyScreen(args: args);
        },
      ),
      GoRoute(
        path: '${PsRoutes.reviews}/:venueId',
        name: 'reviews_list',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['venueId'] ?? '');
          return VenueReviewsListScreen(venueId: id);
        },
      ),
      GoRoute(
        path: '${PsRoutes.writeReview}/:venueId',
        name: 'write_a_review',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['venueId'] ?? '');
          return WriteReviewScreen(venueId: id);
        },
      ),
      GoRoute(
        path: PsRoutes.recommendations,
        name: 'smart_recommendations',
        builder: (context, state) =>
            const PlaceholderScreen(stitchId: 'smart_recommendations'),
      ),
      GoRoute(
        path: PsRoutes.suggestEntry,
        name: 'suggest_a_place_entry',
        builder: (context, state) => const SuggestEntryScreen(),
      ),
      GoRoute(
        path: PsRoutes.suggestForm,
        name: 'suggest_place_form',
        builder: (context, state) => const SuggestFormScreen(),
      ),
      GoRoute(
        path: PsRoutes.suggestSuccess,
        name: 'suggestion_confirmed_2',
        builder: (context, state) {
          final x = state.extra;
          if (x is CreateSuggestionResult) {
            return SuggestSuccessScreen(result: x);
          }
          return const SuggestSuccessFallbackScreen();
        },
      ),
    ],
  );
}
