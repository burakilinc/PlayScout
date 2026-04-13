import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/event_list_item.dart';
import '../logic/event_display.dart';
import 'events_fallback_image.dart';

/// Stitch “Happening Nearby” vertical list (degraded: no rating / distance).
class EventsNearbySection extends StatelessWidget {
  const EventsNearbySection({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  final List<EventListItem> events;
  final void Function(EventListItem e) onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
          child: Text(
            l10n.eventsHappeningNearby,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: PsColors.primary,
            ),
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
            child: Text(
              l10n.eventsNoVenueLinked,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
            child: Column(
              children: [
                for (final e in events) ...[
                  _NearbyRow(l10n: l10n, localeTag: localeTag, event: e, onTap: () => onEventTap(e)),
                  const SizedBox(height: PsSpacing.md),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _NearbyRow extends StatelessWidget {
  const _NearbyRow({required this.l10n, required this.localeTag, required this.event, required this.onTap});

  final AppLocalizations l10n;
  final String localeTag;
  final EventListItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PsRadii.md),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: EventsFallbackImage(height: 96, icon: Icons.event_rounded),
                ),
              ),
              const SizedBox(width: PsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      formatEventNearbyWhen(l10n, localeTag, event),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.secondary,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      event.venueName ?? event.locationSummary ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PsColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
