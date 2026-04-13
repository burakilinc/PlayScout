import 'package:flutter/widgets.dart';

import '../features/favorites/favorites_catalog.dart';

class FavoritesScope extends InheritedNotifier<FavoritesCatalog> {
  const FavoritesScope({
    super.key,
    required FavoritesCatalog catalog,
    required super.child,
  }) : super(notifier: catalog);

  static FavoritesCatalog of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(s != null, 'FavoritesScope missing');
    return s!.notifier!;
  }
}
