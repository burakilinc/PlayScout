import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

class InteractiveMapMyLocationButton extends StatelessWidget {
  const InteractiveMapMyLocationButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: PsSpacing.sm),
        child: Material(
          color: PsColors.surfaceContainerLowest,
          elevation: 6,
          shadowColor: const Color(0xFF36392B).withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(PsSpacing.md),
              child: Icon(Icons.my_location_rounded, color: PsColors.primary, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
