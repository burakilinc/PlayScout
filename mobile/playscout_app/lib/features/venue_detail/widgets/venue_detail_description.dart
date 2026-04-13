import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch description paragraph.
class VenueDetailDescription extends StatelessWidget {
  const VenueDetailDescription({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: PsColors.onSurfaceVariant,
      ),
    );
  }
}
