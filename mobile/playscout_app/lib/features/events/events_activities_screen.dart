import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../home_discover/models/event_list_item.dart';
import 'events_activities_controller.dart';
import 'models/events_list_args.dart';
import 'widgets/events_chip_row.dart';
import 'widgets/events_featured_hero.dart';
import 'widgets/events_learning_grid.dart';
import 'widgets/events_nearby_section.dart';
import 'widgets/events_screen_header.dart';
import 'widgets/events_weekend_section.dart';

/// Stitch `events_activities` — body only; [PlayScoutShell] provides bottom navigation.
class EventsActivitiesScreen extends StatefulWidget {
  const EventsActivitiesScreen({super.key});

  @override
  State<EventsActivitiesScreen> createState() => _EventsActivitiesScreenState();
}

class _EventsActivitiesScreenState extends State<EventsActivitiesScreen> {
  late final EventsActivitiesController _controller = EventsActivitiesController()..load();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openEvent(EventListItem e) {
    context.push('${PsRoutes.eventDetail}/${e.id}');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = 88 + MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: PsColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const EventsScreenHeader(),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final l10n = AppLocalizations.of(context);
                if (_controller.loading) {
                  return const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
                    ),
                  );
                }
                if (_controller.error != null) {
                  return _ErrorBody(message: _controller.error!, onRetry: _controller.load);
                }
                final filtered = _controller.filtered;
                final hero = _controller.hero;
                if (filtered.isEmpty) {
                  return _EmptyBody(thisWeekend: _controller.chips.thisWeekend, onRetry: _controller.load);
                }
                return ListView(
                  padding: EdgeInsets.only(bottom: bottomPad),
                  children: [
                    const SizedBox(height: PsSpacing.sm),
                    EventsChipRow(
                      chips: _controller.chips,
                      onToggle: _controller.toggleChip,
                    ),
                    const SizedBox(height: PsSpacing.xl),
                    if (hero != null) ...[
                      EventsFeaturedHero(event: hero, onTap: () => _openEvent(hero)),
                      const SizedBox(height: PsSpacing.xl + PsSpacing.sm),
                    ],
                    EventsWeekendSection(
                      events: _controller.weekendRail,
                      onSeeAll: () => context.push(
                        PsRoutes.eventsList,
                        extra: EventsListArgs(
                          chips: _controller.chips,
                          sectionTitle: l10n.eventsWeekendFun,
                          weekendRailOnly: true,
                        ),
                      ),
                      onEventTap: _openEvent,
                    ),
                    const SizedBox(height: PsSpacing.xl + PsSpacing.sm),
                    EventsNearbySection(
                      events: _controller.nearbyRows,
                      onEventTap: _openEvent,
                    ),
                    const SizedBox(height: PsSpacing.xl + PsSpacing.sm),
                    EventsLearningGrid(
                      onTileTap: (title, keyword) => context.push(
                        PsRoutes.eventsList,
                        extra: EventsListArgs(
                          chips: _controller.chips,
                          sectionTitle: title,
                          titleKeyword: keyword,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: PsColors.error.withValues(alpha: 0.85)),
            const SizedBox(height: PsSpacing.md),
            Text(
              l10n.eventsSomethingWrong,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.lg),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.thisWeekend, required this.onRetry});

  final bool thisWeekend;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final msg = thisWeekend ? l10n.eventsNoEventsWeekend : l10n.eventsNoEventsFilters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 56, color: PsColors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: PsSpacing.md),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PsColors.onSurface,
              ),
            ),
            const SizedBox(height: PsSpacing.lg),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.refresh)),
          ],
        ),
      ),
    );
  }
}
