import 'package:flutter/widgets.dart';

import '../features/favorites/favorites_store.dart';

class FavoritesScope extends InheritedNotifier<FavoritesStore> {
  const FavoritesScope({
    super.key,
    required FavoritesStore store,
    required super.child,
  }) : super(notifier: store);

  static FavoritesStore of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(s != null, 'FavoritesScope missing');
    return s!.notifier!;
  }
}
