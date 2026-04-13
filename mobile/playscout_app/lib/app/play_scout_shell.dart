import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

/// Bottom navigation for primary discover surfaces (matches Stitch IA intent).
class PlayScoutShell extends StatelessWidget {
  const PlayScoutShell({super.key, required this.child});

  final Widget child;

  static const _paths = [
    PsRoutes.home,
    PsRoutes.map,
    PsRoutes.events,
    PsRoutes.favorites,
  ];

  int _indexForLocation(String path) {
    if (path.startsWith(PsRoutes.map) || path.startsWith(PsRoutes.mapList)) return 1;
    if (path.startsWith(PsRoutes.events)) return 2;
    if (path.startsWith(PsRoutes.favorites)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexForLocation(location);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: l10n.navDiscover,
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: l10n.navEvents,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}
