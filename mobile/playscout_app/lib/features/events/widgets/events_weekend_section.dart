import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/event_list_item.dart';
import 'events_weekend_rail_card.dart';

/// Stitch “Weekend Fun” header + horizontal rail.
class EventsWeekendSection extends StatelessWidget {
  const EventsWeekendSection({
    super.key,
    required this.events,
    required this.onSeeAll,
    required this.onEventTap,
  });

  final List<EventListItem> events;
  final VoidCallback onSeeAll;
  final void Function(EventListItem e) onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.eventsWeekendFun,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PsColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  l10n.eventsSeeAll,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PsColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
            child: Text(
              l10n.eventsNoWeekendPicks,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
          )
        else
          SizedBox(
            height: 292,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(PsSpacing.lg, 0, PsSpacing.lg, PsSpacing.md),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(width: PsSpacing.md),
              itemBuilder: (context, i) {
                final e = events[i];
                return EventsWeekendRailCard(event: e, onTap: () => onEventTap(e));
              },
            ),
          ),
      ],
    );
  }
}
