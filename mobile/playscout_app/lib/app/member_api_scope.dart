import 'package:flutter/material.dart';

import '../features/suggestions/data/suggestions_repository.dart';
import '../features/venue_detail/data/reviews_write_repository.dart';

/// Member-only API clients (Bearer via [AuthAwareHttpClient]).
class MemberApiScope extends InheritedWidget {
  const MemberApiScope({
    super.key,
    required this.reviewsWrite,
    required this.suggestions,
    required super.child,
  });

  final ReviewsWriteRepository reviewsWrite;
  final SuggestionsRepository suggestions;

  static MemberApiScope of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<MemberApiScope>();
    if (s == null) {
      throw StateError('MemberApiScope.of() called with no MemberApiScope ancestor.');
    }
    return s;
  }

  @override
  bool updateShouldNotify(MemberApiScope oldWidget) =>
      reviewsWrite != oldWidget.reviewsWrite || suggestions != oldWidget.suggestions;
}
