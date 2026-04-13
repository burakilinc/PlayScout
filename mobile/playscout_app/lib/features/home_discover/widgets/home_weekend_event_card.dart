import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../models/event_list_item.dart';

/// Stitch horizontal event card for “This Weekend”.
class HomeWeekendEventCard extends StatelessWidget {
  const HomeWeekendEventCard({
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
    final whenFormat = DateFormat('EEE, MMM d • HH:mm', localeTag);
    final meta = event.venueName ?? event.locationSummary ?? l10n.eventsGenericTitle;
    return SizedBox(
      width: 280,
      child: Material(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 128,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PsColors.primary.withValues(alpha: 0.25),
                        PsColors.secondary.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(Icons.celebration_rounded, size: 48, color: PsColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PsSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: PsColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: PsSpacing.xs),
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
                      whenFormat.format(event.startsAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: PsSpacing.md),
                    OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PsColors.primary,
                        side: BorderSide(color: PsColors.primary.withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.sm),
                      ),
                      child: Text(l10n.details),
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
