import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

class FilterOptionsDragHandle extends StatelessWidget {
  const FilterOptionsDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsSpacing.md),
      child: Center(
        child: Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: PsColors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}
