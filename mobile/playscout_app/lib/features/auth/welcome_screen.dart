import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/language_picker_sheet.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import 'auth_session.dart';
import 'data/auth_api_repository.dart';
import 'stitch_auth_assets.dart';
import 'widgets/auth_messages.dart';
import 'widgets/auth_svgs.dart';

/// Stitch `welcome_to_playscout` — hero, brand stack, social + email + guest, legal footer.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busy = false;

  Future<void> _snack(String text) async {
    if (!mounted || text.isEmpty) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onGoogle(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final tokens = await session.signInWithGoogleIdToken();
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.addFavorite(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) router.go(PsRoutes.home);
    } catch (e) {
      if (!mounted) return;
      if (!authErrorIsSilent(e)) await _snack(authErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onApple(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final tokens = await session.signInWithAppleTokens();
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.addFavorite(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) router.go(PsRoutes.home);
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

  Future<void> _onGuest(AuthSession session) async {
    final router = GoRouter.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final tokens = await session.continueAsGuest();
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(router);
      if (!mounted) return;
      if (!d.navigated) router.go(PsRoutes.home);
    } catch (e) {
      if (!mounted) return;
      await _snack(authErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AuthScope.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: PsColors.surface,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _WelcomeHeroBackdrop(),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: _busy ? null : () => showLanguagePickerSheet(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 18, color: PsColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        currentLanguageLabel(context),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: PsColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: AbsorbPointer(
              absorbing: _busy,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        _BrandBlock(theme: theme),
                        const SizedBox(height: 48),
                        _GoogleButton(
                          onPressed: _busy ? null : () => _onGoogle(session),
                        ),
                        const SizedBox(height: 16),
                        _AppleWelcomeButton(
                          onPressed: _busy ? null : () => _onApple(session),
                        ),
                        const SizedBox(height: 16),
                        _SecondaryEmailButton(
                          onPressed: _busy ? null : () => context.push(PsRoutes.authLogin),
                        ),
                        const SizedBox(height: 24),
                        _GuestLink(
                          onPressed: _busy ? null : () => _onGuest(session),
                        ),
                        const SizedBox(height: 48),
                        _LegalFooter(
                          theme: theme,
                          onLegalTap: () =>
                              _snack(l10n.welcomeTermsPrivacySoon),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_busy)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: ModalBarrier(color: Color(0x11000000), dismissible: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _WelcomeHeroBackdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 384,
                height: 384,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PsColors.secondaryContainer.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            top: h * 0.22,
            left: -128,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PsColors.tertiaryContainer.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.5,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.32,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    StitchAuthAssets.welcomePlaygroundHero,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        ColoredBox(color: PsColors.secondaryContainer.withValues(alpha: 0.25)),
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: PsColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: PsColors.primary.withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const SizedBox(
            width: 80,
            height: 80,
            child: Icon(Icons.explore_rounded, size: 52, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.appTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: PsColors.primary,
            letterSpacing: -0.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.welcomeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: PsColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: PsColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF36392B).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
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
                  l10n.continueWithGoogle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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

class _AppleWelcomeButton extends StatelessWidget {
  const _AppleWelcomeButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: PsColors.onSurface,
      borderRadius: BorderRadius.circular(999),
      elevation: 6,
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
              const AuthAppleLogo(size: 20, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                l10n.continueWithApple,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryEmailButton extends StatelessWidget {
  const _SecondaryEmailButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: PsColors.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Center(
            child: Text(
              l10n.continueWithEmail,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: PsColors.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestLink extends StatelessWidget {
  const _GuestLink({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: PsColors.tertiary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.continueAsGuest,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 13,
                color: PsColors.tertiary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: PsColors.tertiary),
          ],
        ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.theme, required this.onLegalTap});

  final ThemeData theme;
  final VoidCallback onLegalTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      height: 1.5,
      color: PsColors.onSurfaceVariant.withValues(alpha: 0.6),
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            height: 1.5,
            color: PsColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          children: [
            TextSpan(text: l10n.legalPrefix),
            TextSpan(
              text: l10n.legalTerms,
              style: linkStyle,
              recognizer: TapGestureRecognizer()..onTap = onLegalTap,
            ),
            TextSpan(text: l10n.legalAnd),
            TextSpan(
              text: l10n.legalPrivacy,
              style: linkStyle,
              recognizer: TapGestureRecognizer()..onTap = onLegalTap,
            ),
          ],
        ),
      ),
    );
  }
}
