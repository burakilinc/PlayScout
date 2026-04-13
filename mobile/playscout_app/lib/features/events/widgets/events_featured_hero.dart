import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';
import '../../home_discover/models/event_list_item.dart';
import '../logic/event_display.dart';
import 'events_fallback_image.dart';

/// Stitch featured hero — first event, no featured flag.
class EventsFeaturedHero extends StatelessWidget {
  const EventsFeaturedHero({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
      child: Material(
        color: PsColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsRadii.xl),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shadowColor: const Color(0xFF36392B).withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const EventsFallbackImage(),
              Positioned(
                top: PsSpacing.md,
                left: PsSpacing.md,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: PsColors.tertiary,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: PsSpacing.md, vertical: PsSpacing.xs + 2),
                    child: Text(
                      l10n.eventsFeaturedBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: PsColors.onTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 132,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(PsSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: const [Shadow(blurRadius: 8, color: Color(0x66000000))],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: PsSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFFFAB69)),
                            const SizedBox(width: PsSpacing.sm),
                            Expanded(
                              child: Text(
                                formatEventHeroWhen(l10n, localeTag, event),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
