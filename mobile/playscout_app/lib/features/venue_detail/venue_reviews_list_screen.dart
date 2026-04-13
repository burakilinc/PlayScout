import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/play_scout_route_observer.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../auth/models/pending_auth_intent.dart';
import '../auth/protected_member_action.dart';
import 'data/venue_detail_repository.dart';
import 'data/venue_reviews_repository.dart';
import 'models/review_preview.dart';
import 'venue_detail_controller.dart';
import 'widgets/parent_review_card.dart';

/// Full-screen parent reviews for a venue (GET /reviews).
class VenueReviewsListScreen extends StatefulWidget {
  VenueReviewsListScreen({
    super.key,
    required this.venueId,
    VenueReviewsRepository? reviewsRepository,
    VenueDetailRepository? venueRepository,
  })  : _reviewsRepository = reviewsRepository ?? VenueReviewsRepository(),
        _venueRepository = venueRepository ?? VenueDetailRepository();

  final String venueId;
  final VenueReviewsRepository _reviewsRepository;
  final VenueDetailRepository _venueRepository;

  @override
  State<VenueReviewsListScreen> createState() => _VenueReviewsListScreenState();
}

class _VenueReviewsListScreenState extends State<VenueReviewsListScreen> with RouteAware {
  List<ReviewPreview>? _reviews;
  String? _venueName;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVenueName();
    _loadReviews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      playScoutRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    playScoutRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadReviews();
  }

  Future<void> _loadVenueName() async {
    try {
      final v = await widget._venueRepository.fetchById(widget.venueId);
      if (mounted) setState(() => _venueName = v.name);
    } catch (_) {
      if (mounted) setState(() => _venueName = null);
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = VenueDetailController.reviewsLanguageTag();
      final list = await widget._reviewsRepository.fetchForVenueForList(
        venueId: widget.venueId,
        language: lang,
      );
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _loading = false;
      });
    } on VenueReviewsVenueNotFoundException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _reviews = const [];
        _error = l10n.venueReviewsNotFound;
        _loading = false;
      });
    } on VenueReviewsUnsupportedLanguageException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _reviews = const [];
        _error = l10n.venueReviewsUnsupportedLang;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _reviews = null;
        _error = l10n.venueReviewsLoadFailed;
        _loading = false;
      });
    }
  }

  Future<void> _onWriteReview() async {
    final id = widget.venueId;
    await playScoutRequireFullMember(
      context,
      resumeIfGuest: PendingAuthIntent.writeReview(id),
      whenMember: () async {
        if (!context.mounted) return;
        final posted = await context.push<bool>('${PsRoutes.writeReview}/$id');
        if ((posted ?? false) && mounted) await _loadReviews();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = _venueName ?? l10n.venueReviewsParentTitle;

    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _loading && _reviews == null ? null : _onWriteReview,
            child: Text(
              l10n.writeReview,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: PsColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: PsColors.primary,
        onRefresh: _loadReviews,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _reviews == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3, color: PsColors.primary),
            ),
          ),
        ],
      );
    }

    if (_error != null && _reviews == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PsSpacing.lg),
        children: [
          const SizedBox(height: 48),
          Icon(Icons.cloud_off_outlined, size: 48, color: PsColors.error.withValues(alpha: 0.85)),
          const SizedBox(height: PsSpacing.md),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
          ),
          const SizedBox(height: PsSpacing.lg),
          Center(child: FilledButton(onPressed: _loadReviews, child: Text(l10n.retry))),
        ],
      );
    }

    final list = _reviews ?? const <ReviewPreview>[];
    if (list.isEmpty) {
      if (_error != null) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(PsSpacing.xl),
          children: [
            const SizedBox(height: 48),
            Icon(Icons.info_outline_rounded, size: 48, color: PsColors.outlineVariant),
            const SizedBox(height: PsSpacing.md),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.lg),
            Center(child: FilledButton(onPressed: _loadReviews, child: Text(l10n.retry))),
          ],
        );
      }
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(PsSpacing.xl),
        children: [
          const SizedBox(height: 48),
          Icon(Icons.rate_review_outlined, size: 48, color: PsColors.outlineVariant),
          const SizedBox(height: PsSpacing.md),
          Text(
            l10n.venueReviewsNoReviews,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: PsColors.onSurface),
          ),
          const SizedBox(height: PsSpacing.sm),
          Text(
            l10n.venueReviewsBeFirst,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSurfaceVariant),
          ),
          const SizedBox(height: PsSpacing.xl),
          Center(
            child: FilledButton.tonal(
              onPressed: _loading ? null : _onWriteReview,
              child: Text(l10n.writeReview),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(PsSpacing.lg, PsSpacing.md, PsSpacing.lg, PsSpacing.xl),
      itemCount: list.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: PsSpacing.md),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: PsSpacing.sm),
            child: Text(
              l10n.venueReviewsParentTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: PsColors.onSurface,
              ),
            ),
          );
        }
        return ParentReviewCard(review: list[i - 1]);
      },
    );
  }
}
