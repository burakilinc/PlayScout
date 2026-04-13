import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';
import '../models/venue_detail.dart';

/// Stitch hero: `h-[400px]`, `rounded-xl`, `shadow-xl`, `1/n` badge.
class VenueDetailHeroCarousel extends StatefulWidget {
  const VenueDetailHeroCarousel({
    super.key,
    required this.images,
  });

  final List<VenueDetailImage> images;

  @override
  State<VenueDetailHeroCarousel> createState() => _VenueDetailHeroCarouselState();
}

class _VenueDetailHeroCarouselState extends State<VenueDetailHeroCarousel> {
  late final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.images.isNotEmpty ? widget.images.map((e) => e.url).toList() : <String>[];
    if (urls.isEmpty) {
      return _HeroShell(
        page: ColoredBox(
          color: PsColors.surfaceContainerHigh,
          child: Center(
            child: Icon(Icons.photo_camera_outlined, size: 56, color: PsColors.primary.withValues(alpha: 0.45)),
          ),
        ),
        badgeText: '0/0',
      );
    }
    return _HeroShell(
      page: PageView.builder(
        controller: _pageController,
        itemCount: urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          return Image.network(
            urls[i],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: PsColors.surfaceContainerHigh,
              child: Icon(Icons.broken_image_outlined, color: PsColors.onSurfaceVariant, size: 48),
            ),
          );
        },
      ),
      badgeText: '${_index + 1}/${urls.length}',
    );
  }
}

class _HeroShell extends StatelessWidget {
  const _HeroShell({required this.page, required this.badgeText});

  final Widget page;
  final String badgeText;

  static const _r = PsRadii.xl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF36392B).withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_r),
              child: page,
            ),
          ),
          Positioned(
            bottom: PsSpacing.lg,
            right: PsSpacing.lg,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
