import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import 'auth_session.dart';
import 'data/auth_api_repository.dart';
import 'guest_prompt_copy.dart';
import 'models/pending_auth_intent.dart';
import 'models/token_bundle.dart';
import 'stitch_auth_assets.dart';
import 'widgets/auth_messages.dart';
import 'widgets/auth_svgs.dart';

/// Stitch `guest_access_prompt` — dimmed blurred shell, bottom sheet, Google / Apple / Email / Maybe later.
class GuestAccessPromptPage extends StatefulWidget {
  const GuestAccessPromptPage({super.key, this.intent});

  /// When opened via router, arms resume intent once.
  final PendingAuthIntent? intent;

  @override
  State<GuestAccessPromptPage> createState() => _GuestAccessPromptPageState();
}

class _GuestAccessPromptPageState extends State<GuestAccessPromptPage> with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slide, curve: const Cubic(0.16, 1, 0.3, 1)));

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _slide.forward();
    final i = widget.intent;
    if (i != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AuthScope.of(context).armResumeIntent(i);
      });
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  Future<void> _snack(String text) async {
    if (!mounted || text.isEmpty) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _afterAuth(AuthSession session, TokenBundle tokens) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    await session.applyTokens(tokens);
    if (!mounted) return;
    router.pop();
    await session.dispatchPendingIntent(
      router,
      onFavoriteResume: session.hasMemberSession ? (id) => fav.addFavorite(venueId: id) : null,
    );
  }

  Future<void> _google(AuthSession session) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final tokens = await session.signInWithGoogleIdToken();
      await _afterAuth(session, tokens);
    } catch (e) {
      if (!mounted) return;
      if (!authErrorIsSilent(e)) await _snack(authErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apple(AuthSession session) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final tokens = await session.signInWithAppleTokens();
      await _afterAuth(session, tokens);
    } catch (e) {
      if (!mounted) return;
      if (e is AuthApiAppleNotImplementedException) {
        await _snack(authErrorMessage(l10n, e));
      } else if (!authErrorIsSilent(e)) {
        await _snack(authErrorMessage(l10n, e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _email(GoRouter router) {
    router.pop();
    router.push(PsRoutes.authLogin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AuthScope.of(context);
    final router = GoRouter.of(context);
    final l10n = AppLocalizations.of(context);
    final copy = guestPromptCopyFor(widget.intent, l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => router.pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: PsColors.onSurface.withValues(alpha: 0.12),
                child: const _FakeShellBehind(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _offset,
              child: Material(
                color: PsColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                clipBehavior: Clip.antiAlias,
                elevation: 16,
                shadowColor: const Color(0xFF36392B).withValues(alpha: 0.1),
                child: AbsorbPointer(
                  absorbing: _busy,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 576),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 32,
                        right: 32,
                        bottom: MediaQuery.paddingOf(context).bottom + 24,
                        top: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: PsColors.outlineVariant.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 40,
                                  child: Container(
                                    width: 128,
                                    height: 128,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PsColors.secondary.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 40,
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PsColors.primary.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Image.network(
                                    StitchAuthAssets.guestKiteIllustration,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            copy.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PsColors.onSurface,
                              letterSpacing: -0.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            copy.body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: PsColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _GuestGoogleButton(onPressed: () => _google(session)),
                          const SizedBox(height: 12),
                          _GuestAppleButton(onPressed: () => _apple(session)),
                          const SizedBox(height: 12),
                          _GuestEmailButton(onPressed: () => _email(router)),
                          const SizedBox(height: 32),
                          TextButton(
                            onPressed: () => router.pop(),
                            child: Text(
                              l10n.guestPromptMaybeLater,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PsColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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

class _FakeShellBehind extends StatelessWidget {
  const _FakeShellBehind();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).appTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: PsColors.primary,
                  ),
                ),
                Icon(Icons.menu_rounded, color: PsColors.primary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 256,
                  decoration: BoxDecoration(
                    color: PsColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(PsRadii.lg),
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 32, width: 220, decoration: BoxDecoration(color: PsColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(99))),
                const SizedBox(height: 12),
                Container(height: 16, decoration: BoxDecoration(color: PsColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(99))),
                const SizedBox(height: 8),
                Container(height: 16, width: 260, decoration: BoxDecoration(color: PsColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(99))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Container(height: 160, decoration: BoxDecoration(color: PsColors.surfaceContainer, borderRadius: BorderRadius.circular(PsRadii.sm)))),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 160, decoration: BoxDecoration(color: PsColors.secondaryContainer, borderRadius: BorderRadius.circular(PsRadii.sm)))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: PsColors.primaryContainer,
                borderRadius: BorderRadius.circular(PsRadii.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestGoogleButton extends StatelessWidget {
  const _GuestGoogleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthGoogleLogo(size: 20),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).continueWithGoogle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PsColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestAppleButton extends StatelessWidget {
  const _GuestAppleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.onSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthAppleLogo(size: 20, color: PsColors.surface),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).continueWithApple,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PsColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestEmailButton extends StatelessWidget {
  const _GuestEmailButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.primary,
      borderRadius: BorderRadius.circular(999),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline_rounded, color: PsColors.onPrimary, size: 22),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).continueWithEmail,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PsColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
