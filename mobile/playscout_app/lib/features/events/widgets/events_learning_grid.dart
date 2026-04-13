import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

typedef LearningTileTap = void Function(String title, String titleKeyword);

/// Stitch “Learning & Skills” 2×2 bento grid.
class EventsLearningGrid extends StatelessWidget {
  const EventsLearningGrid({super.key, required this.onTileTap});

  final LearningTileTap onTileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final tiles = <({
      String title,
      String keyword,
      IconData icon,
      Color iconColor,
      Color hoverHint,
    })>[
      (
        title: l10n.artWorkshops,
        keyword: 'art',
        icon: Icons.palette_rounded,
        iconColor: PsColors.secondary,
        hoverHint: PsColors.secondaryContainer,
      ),
      (
        title: l10n.codingForKids,
        keyword: 'cod',
        icon: Icons.code_rounded,
        iconColor: PsColors.primary,
        hoverHint: PsColors.primaryContainer,
      ),
      (
        title: l10n.musicTheory,
        keyword: 'music',
        icon: Icons.music_note_rounded,
        iconColor: PsColors.tertiary,
        hoverHint: PsColors.tertiaryContainer,
      ),
      (
        title: l10n.scienceLab,
        keyword: 'science',
        icon: Icons.science_rounded,
        iconColor: PsColors.error,
        hoverHint: PsColors.errorContainer,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
          child: Text(
            l10n.eventsLearningSkills,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: PsColors.primary,
            ),
          ),
        ),
        const SizedBox(height: PsSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: PsSpacing.md,
            crossAxisSpacing: PsSpacing.md,
            childAspectRatio: 1.05,
            children: [
              for (final t in tiles)
                _LearningTile(
                  title: t.title,
                  icon: t.icon,
                  iconColor: t.iconColor,
                  hoverHint: t.hoverHint,
                  onTap: () => onTileTap(t.title, t.keyword),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningTile extends StatefulWidget {
  const _LearningTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.hoverHint,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color hoverHint;
  final VoidCallback onTap;

  @override
  State<_LearningTile> createState() => _LearningTileState();
}

class _LearningTileState extends State<_LearningTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: _pressed ? widget.hoverHint.withValues(alpha: 0.85) : PsColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(PsRadii.md),
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: BorderRadius.circular(PsRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PsColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: PsColors.parkShadow(blur: 4, y: 2),
                ),
                child: Icon(widget.icon, color: widget.iconColor),
              ),
              const SizedBox(height: PsSpacing.md),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PsColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
