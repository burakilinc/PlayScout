import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../home_discover/models/venue_summary.dart';
import 'widgets/interactive_map_distance_format.dart';

/// Full list of venues from the map session (Stitch “List view” follow-up).
class InteractiveParkMapListScreen extends StatelessWidget {
  const InteractiveParkMapListScreen({
    super.key,
    required this.venues,
  });

  final List<VenueSummary> venues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.surface,
      appBar: AppBar(
        backgroundColor: PsColors.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: PsColors.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.nearbyPlaces,
          style: theme.textTheme.titleMedium?.copyWith(
            color: PsColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: venues.isEmpty
          ? Center(
              child: Text(
                l10n.noVenuesToShow,
                style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.md, PsSpacing.lg, PsSpacing.xl),
              itemCount: venues.length,
              separatorBuilder: (context, index) => const SizedBox(height: PsSpacing.md),
              itemBuilder: (context, i) {
                final v = venues[i];
                return Material(
                  color: PsColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(PsRadii.md),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(PsRadii.md),
                    onTap: () => context.push('${PsRoutes.venue}/${v.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(PsSpacing.md),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(PsRadii.sm),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: v.primaryImageUrl != null
                                  ? Image.network(v.primaryImageUrl!, fit: BoxFit.cover)
                                  : ColoredBox(
                                      color: PsColors.surfaceContainerHigh,
                                      child: Icon(Icons.park_rounded, color: PsColors.primary.withValues(alpha: 0.35)),
                                    ),
                            ),
                          ),
                          const SizedBox(width: PsSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: PsColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  InteractiveMapDistanceFormat.kmAway(l10n, v.distanceMeters),
                                  style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: PsColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
