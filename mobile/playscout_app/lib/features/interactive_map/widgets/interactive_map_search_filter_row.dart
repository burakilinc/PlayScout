import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/user_location.dart';

class InteractiveMapSearchFilterRow extends StatelessWidget {
  const InteractiveMapSearchFilterRow({
    super.key,
    required this.location,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final UserLocation location;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  static String _areaLabel(UserLocation u) {
    final parts = u.displayLabel.split(',');
    return parts.first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Material(
            color: PsColors.surfaceContainerLowest,
            elevation: 6,
            shadowColor: const Color(0xFF36392B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9999),
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(9999),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(PsSpacing.md, PsSpacing.md, PsSpacing.md, PsSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: PsColors.onSurfaceVariant, size: 22),
                    const SizedBox(width: PsSpacing.sm),
                    Expanded(
                      child: Text(
                        'Search parks, indoor places...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PsColors.onSurfaceVariant.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: PsSpacing.sm),
                      color: PsColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.xs),
                      decoration: BoxDecoration(
                        color: PsColors.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, color: PsColors.secondary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _areaLabel(location),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: PsColors.onSecondaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: PsSpacing.md),
        Material(
          color: PsColors.surfaceContainerLowest,
          elevation: 6,
          shadowColor: const Color(0xFF36392B).withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onFilterTap,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(PsSpacing.md),
              child: Icon(Icons.filter_list_rounded, color: PsColors.primary, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}
