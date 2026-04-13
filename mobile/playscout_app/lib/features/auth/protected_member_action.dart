import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_scope.dart';
import '../../app/router.dart';
import 'models/pending_auth_intent.dart';

/// Guest / anonymous → guest sheet with resume; full member → [whenMember].
Future<void> playScoutRequireFullMember(
  BuildContext context, {
  required PendingAuthIntent resumeIfGuest,
  required Future<void> Function() whenMember,
}) async {
  final auth = AuthScope.of(context);
  if (auth.hasMemberSession) {
    await whenMember();
    return;
  }
  if (!context.mounted) return;
  await context.push(PsRoutes.guestPrompt, extra: resumeIfGuest);
}
