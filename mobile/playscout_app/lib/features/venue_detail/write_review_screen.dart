import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/member_api_scope.dart';
import '../../design_system/design_tokens.dart';
import '../auth/models/pending_auth_intent.dart';
import '../auth/protected_member_action.dart';
import 'data/reviews_write_repository.dart';
import 'data/venue_detail_repository.dart';
import 'review_language.dart';

/// Authenticated review compose; [venueId] from route.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, required this.venueId});

  final String venueId;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _comment = TextEditingController();
  final _detail = VenueDetailRepository();

  int _rating = 5;
  int? _clean;
  int? _safety;
  int? _suitability;
  String? _venueName;
  bool _loadingVenue = true;
  bool _submitting = false;
  String? _banner;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _loadVenue();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _loadVenue() async {
    try {
      final v = await _detail.fetchById(widget.venueId);
      if (mounted) setState(() => _venueName = v.name);
    } catch (_) {
      if (mounted) setState(() => _venueName = null);
    } finally {
      if (mounted) setState(() => _loadingVenue = false);
    }
  }

  String _originalLanguageCode() {
    final loc = Localizations.localeOf(context);
    final raw = normalizeReviewLanguageTag(loc.toLanguageTag()) ?? normalizeReviewLanguageTag(loc.languageCode);
    if (raw != null && isSupportedReviewLanguage(raw)) return raw;
    return 'en';
  }

  String? _validateComment(AppLocalizations l10n, String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 20) return l10n.writeReviewCommentMinLen;
    if (t.length > 4000) return l10n.writeReviewCommentMaxLen;
    var words = 0;
    var inWord = false;
    for (final c in t.runes) {
      final ch = String.fromCharCode(c);
      if (RegExp(r'\s').hasMatch(ch)) {
        inWord = false;
      } else if (!inWord) {
        inWord = true;
        words++;
      }
    }
    if (words < 3) return l10n.writeReviewCommentMinWords;
    if (t.length >= 2) {
      final first = t[0];
      var allSame = true;
      for (final c in t.runes) {
        if (String.fromCharCode(c) != first) {
          allSame = false;
          break;
        }
      }
      if (allSame) return l10n.writeReviewCommentRepeated;
    }
    return null;
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    if (!auth.hasMemberSession) {
      await playScoutRequireFullMember(
        context,
        resumeIfGuest: PendingAuthIntent.writeReview(widget.venueId),
        whenMember: () async {
          if (context.mounted) await _submit();
        },
      );
      return;
    }

    setState(() {
      _banner = null;
      _commentError = null;
    });
    final l10nSubmit = AppLocalizations.of(context);
    final err = _validateComment(l10nSubmit, _comment.text);
    if (err != null) {
      setState(() => _commentError = err);
      return;
    }
    if (_rating < 1 || _rating > 5) {
      setState(() => _banner = l10nSubmit.writeReviewPickRating);
      return;
    }

    setState(() => _submitting = true);
    try {
      await MemberApiScope.of(context).reviewsWrite.create(
            venueId: widget.venueId,
            rating: _rating,
            comment: _comment.text.trim(),
            originalLanguage: _originalLanguageCode(),
            cleanlinessScore: _clean,
            safetyScore: _safety,
            suitabilityForSmallChildrenScore: _suitability,
          );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reviewPostedThanks)));
      context.pop(true);
    } on ReviewAlreadyExistsException {
      if (!mounted) return;
      setState(() => _banner = AppLocalizations.of(context).writeReviewAlreadyExists);
    } on ReviewsValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _commentError = e.firstForField('comment');
        _banner = _commentError == null ? e.combinedMessage() : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _banner = AppLocalizations.of(context).writeReviewCouldNotPost);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = AuthScope.of(context);
    final l10n = AppLocalizations.of(context);
    final title = _loadingVenue ? l10n.writeReview : (_venueName ?? l10n.writeReview);

    if (!auth.hasMemberSession) {
      return Scaffold(
        backgroundColor: PsColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(l10n.writeReview),
        ),
        body: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.signInToPostReview,
                style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
              ),
              const SizedBox(height: PsSpacing.xl),
              FilledButton(
                onPressed: () => playScoutRequireFullMember(
                  context,
                  resumeIfGuest: PendingAuthIntent.writeReview(widget.venueId),
                  whenMember: () async {
                    if (context.mounted) setState(() {});
                  },
                ),
                child: Text(l10n.continueText),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PsColors.background,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(PsSpacing.lg),
          children: [
            if (_banner != null) ...[
              Material(
                color: PsColors.secondaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(PsRadii.sm),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: PsColors.secondary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _banner!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PsSpacing.lg),
            ],
            Text(
              l10n.writeReviewOverallRating,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.sm),
            Row(
              children: List.generate(5, (i) {
                final n = i + 1;
                final on = n <= _rating;
                return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _rating = n),
                  icon: Icon(
                    Icons.star_rounded,
                    size: 40,
                    color: on ? PsColors.tertiary : PsColors.outlineVariant.withValues(alpha: 0.35),
                  ),
                );
              }),
            ),
            const SizedBox(height: PsSpacing.xl),
            TextFormField(
              controller: _comment,
              minLines: 5,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: l10n.writeReviewYourReview,
                alignLabelWithHint: true,
                errorText: _commentError,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
              ),
            ),
            const SizedBox(height: PsSpacing.md),
            Text(
              l10n.writeReviewWrittenInAppLang(_originalLanguageCode().toUpperCase()),
              style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.xl),
            Text(
              l10n.writeReviewOptionalScores,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PsSpacing.sm),
            _OptionalScore(
              label: l10n.cleanliness,
              value: _clean,
              onChanged: (v) => setState(() => _clean = v),
            ),
            _OptionalScore(
              label: l10n.safety,
              value: _safety,
              onChanged: (v) => setState(() => _safety = v),
            ),
            _OptionalScore(
              label: l10n.goodForSmallChildren,
              value: _suitability,
              onChanged: (v) => setState(() => _suitability = v),
            ),
            const SizedBox(height: PsSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: PsColors.onPrimary),
                    )
                  : Text(l10n.postReview),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalScore extends StatelessWidget {
  const _OptionalScore({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: PsSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          DropdownButton<int?>(
            value: value,
            hint: Text(l10n.dashEmDash),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.skip)),
              for (var i = 1; i <= 5; i++) DropdownMenuItem<int?>(value: i, child: Text('$i')),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
