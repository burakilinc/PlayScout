import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/event_list_item.dart';
import '../logic/event_display.dart';
import 'events_fallback_image.dart';

/// Stitch horizontal weekend card (~260px wide, tall image band).
class EventsWeekendRailCard extends StatelessWidget {
  const EventsWeekendRailCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final EventListItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return SizedBox(
      width: 260,
      child: Material(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 160,
                width: double.infinity,
                child: EventsFallbackImage(height: 160, icon: Icons.park_rounded),
              ),
              Padding(
                padding: const EdgeInsets.all(PsSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PsColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      formatEventRailWhen(localeTag, event),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PsColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.xs),
                    Text(
                      formatEventAgeLine(l10n, event),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PsColors.secondary,
                      ),
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
