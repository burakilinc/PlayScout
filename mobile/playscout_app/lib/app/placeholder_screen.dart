import 'package:flutter/material.dart';

import '../design_system/design_tokens.dart';

/// Temporary shell until Stitch screens are ported 1:1.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.stitchId,
    this.extraLabel,
  });

  /// Stitch folder name (source of truth mapping).
  final String stitchId;
  final String? extraLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stitchId)),
      body: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stitchId,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (extraLabel != null) ...[
              const SizedBox(height: PsSpacing.sm),
              Text(
                extraLabel!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: PsSpacing.lg),
            Text(
              'Placeholder — implement from Stitch HTML only.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
