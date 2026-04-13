import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch top title row (no menu, no avatar per product).
class EventsScreenHeader extends StatelessWidget {
  const EventsScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.md, PsSpacing.lg, PsSpacing.md),
      child: Center(
        child: Text(
          'Events',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: PsColors.primary,
            letterSpacing: -0.02,
          ),
        ),
      ),
    );
  }
}
