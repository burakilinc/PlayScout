import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch fixed `<nav>`: back, title "Venue Details", favorite, share.
class VenueDetailTopNav extends StatelessWidget {
  const VenueDetailTopNav({
    super.key,
    required this.title,
    required this.onBack,
    required this.onFavoriteTap,
    required this.onShareTap,
    required this.favoriteSelected,
    this.favoriteBusy = false,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;
  final bool favoriteSelected;
  final bool favoriteBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PsColors.surface.withValues(alpha: 0.8),
            boxShadow: PsColors.parkShadow(blur: 32, y: 8),
          ),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg),
              child: Row(
                children: [
                  _CircleIconButton(
                    onPressed: onBack,
                    icon: Icons.arrow_back_rounded,
                    iconColor: PsColors.primary,
                  ),
                  const SizedBox(width: PsSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: PsColors.primary,
                      ),
                    ),
                  ),
                  favoriteBusy
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: PsColors.primary),
                            ),
                          ),
                        )
                      : _CircleIconButton(
                          onPressed: onFavoriteTap,
                          icon: favoriteSelected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          iconColor: favoriteSelected ? PsColors.error : PsColors.primary,
                        ),
                  const SizedBox(width: PsSpacing.sm),
                  _CircleIconButton(
                    onPressed: onShareTap,
                    icon: Icons.share_rounded,
                    iconColor: PsColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PsColors.surfaceContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}
