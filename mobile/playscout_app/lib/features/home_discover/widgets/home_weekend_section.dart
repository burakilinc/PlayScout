import 'package:flutter/material.dart';

import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/event_list_item.dart';
import 'home_weekend_event_card.dart';

/// Stitch “This Weekend” block + horizontal list.
class HomeWeekendSection extends StatelessWidget {
  const HomeWeekendSection({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  final List<EventListItem> events;
  final void Function(EventListItem event) onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
          child: Text(
            l10n.homeWeekendHeading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: PsColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
            child: Text(
              l10n.homeWeekendEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(width: PsSpacing.md),
              itemBuilder: (context, i) {
                final e = events[i];
                return HomeWeekendEventCard(
                  event: e,
                  onTap: () => onEventTap(e),
                );
              },
            ),
          ),
      ],
    );
  }
}
