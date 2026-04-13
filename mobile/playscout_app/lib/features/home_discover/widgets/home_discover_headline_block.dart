import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch greeting block: headline + location pill (below top bar, in scroll body).
class HomeDiscoverHeadlineBlock extends StatelessWidget {
  const HomeDiscoverHeadlineBlock({
    super.key,
    required this.headline,
    required this.subline,
    required this.locationLine,
    required this.onLocationPillTap,
  });

  final String headline;
  final String subline;
  final String locationLine;
  final VoidCallback onLocationPillTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: PsColors.onSurface,
            height: 1.15,
          ),
        ),
        if (subline.isNotEmpty) ...[
          const SizedBox(height: PsSpacing.xs),
          Text(
            subline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: PsColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: PsSpacing.md),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLocationPillTap,
            borderRadius: BorderRadius.circular(PsRadii.xl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.sm),
              decoration: BoxDecoration(
                color: PsColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(PsRadii.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: PsColors.secondary),
                  const SizedBox(width: PsSpacing.xs),
                  Flexible(
                    child: Text(
                      locationLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PsColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
