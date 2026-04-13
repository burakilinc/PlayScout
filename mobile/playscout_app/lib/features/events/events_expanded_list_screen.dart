import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../home_discover/models/event_list_item.dart';
import 'data/events_api_repository.dart';
import 'logic/event_calendar.dart' show eventQueryUtcRange, startsInWeekendWindow, weekendSaturdayStart;
import 'logic/event_display.dart';
import 'logic/event_filters.dart' show applyEventChips, applyTitleKeyword;
import 'models/events_list_args.dart';

/// Expanded list from “See all” or Learning tiles — same card fields, vertical stack.
class EventsExpandedListScreen extends StatefulWidget {
  const EventsExpandedListScreen({super.key, required this.args});

  final EventsListArgs args;

  @override
  State<EventsExpandedListScreen> createState() => _EventsExpandedListScreenState();
}

class _EventsExpandedListScreenState extends State<EventsExpandedListScreen> {
  final EventsApiRepository _repo = EventsApiRepository();
  List<EventListItem> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final range = eventQueryUtcRange(widget.args.chips);
      var list = await _repo.fetchEvents(fromUtc: range.$1, toUtc: range.$2, pageSize: 100);
      list = applyEventChips(list, widget.args.chips);
      list = applyTitleKeyword(list, widget.args.titleKeyword);
      if (widget.args.weekendRailOnly) {
        final sat = weekendSaturdayStart(DateTime.now());
        list = list.where((e) => startsInWeekendWindow(e.startsAt, sat)).toList();
      }
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
        _items = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(
        backgroundColor: PsColors.background,
        foregroundColor: PsColors.onSurface,
        elevation: 0,
        title: Text(
          widget.args.sectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildBody(theme, l10n),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: PsColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.eventsSomethingWrong, textAlign: TextAlign.center),
              const SizedBox(height: PsSpacing.md),
              FilledButton(onPressed: _load, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Text(
            l10n.eventsNoEventsMatchFilters,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.sm, PsSpacing.lg, PsSpacing.xl),
      itemCount: _items.length,
      separatorBuilder: (context, index) => const SizedBox(height: PsSpacing.md),
      itemBuilder: (context, i) {
        final e = _items[i];
        return Material(
          color: PsColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(PsRadii.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(PsRadii.md),
            onTap: () => context.push('${PsRoutes.eventDetail}/${e.id}'),
            child: Padding(
              padding: const EdgeInsets.all(PsSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PsColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.xs),
                  Text(
                    formatEventRailWhen(localeTag, e),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PsColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PsSpacing.xs),
                  Text(
                    formatEventAgeLine(l10n, e),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PsColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
