import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/favorites_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import 'auth_session.dart';
import 'data/auth_api_repository.dart';
import 'widgets/auth_coral_submit_button.dart';
import 'widgets/auth_messages.dart';
import 'widgets/auth_pill_text_field.dart';
import 'widgets/auth_svgs.dart';

/// Stitch `login` — top bar, card with email/password, divider, compact social, sign-up link.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  bool _loading = false;
  String? _banner;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _snack(String text) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _emailError = null;
      _passwordError = null;
    });
    setState(() => _loading = true);
    try {
      final tokens = await session.loginEmailPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.ensureFavorited(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) {
        if (context.canPop()) {
          context.pop();
        } else {
          router.go(PsRoutes.home);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (e is AuthApiValidationException) {
        setState(() {
          _emailError = e.firstMessageFor('Email') ?? e.firstMessageFor('email');
          _passwordError = e.firstMessageFor('Password') ?? e.firstMessageFor('password');
          if (_emailError == null && _passwordError == null) {
            _banner = e.combinedMessage();
          }
        });
      } else {
        setState(() => _banner = authErrorMessage(l10n, e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _socialGoogle(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _loading = true;
    });
    try {
      final tokens = await session.signInWithGoogleIdToken();
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.ensureFavorited(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) {
        if (context.canPop()) {
          context.pop();
        } else {
          router.go(PsRoutes.home);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (!authErrorIsSilent(e)) await _snack(authErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _socialApple(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _loading = true;
    });
    try {
      final tokens = await session.signInWithAppleTokens();
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.ensureFavorited(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) {
        if (context.canPop()) {
          context.pop();
        } else {
          router.go(PsRoutes.home);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (e is AuthApiAppleNotImplementedException) {
        await _snack(authErrorMessage(l10n, e));
      } else if (!authErrorIsSilent(e)) {
        await _snack(authErrorMessage(l10n, e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AuthScope.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: PsColors.surface,
      body: Column(
        children: [
          _LoginTopBar(onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(PsRoutes.home);
            }
          }),
          Expanded(
            child: Stack(
              children: [
                _BlobDecor(),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        children: [
                          if (_banner != null) ...[
                            Material(
                              color: PsColors.secondaryContainer.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(PsRadii.sm),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: PsColors.secondary, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _banner!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: PsColors.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: PsColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(PsRadii.lg),
                              boxShadow: PsColors.parkShadow(blur: 32, y: 8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.authWelcomeBack,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: PsColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.authStepBack,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: PsColors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  AuthPillTextField(
                                    controller: _email,
                                    focusNode: _emailFocus,
                                    label: l10n.emailAddress,
                                    hintText: 'hello@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    errorText: _emailError,
                                    onSubmitted: (_) => _pwFocus.requestFocus(),
                                    suffixIcon: Icon(Icons.mail_outline_rounded, color: PsColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.password,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: PsColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.push(PsRoutes.authForgot),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 32),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: PsColors.primary,
                                        ),
                                        child: Text(
                                          l10n.forgotPassword,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: PsColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  AuthPillTextField(
                                    controller: _password,
                                    focusNode: _pwFocus,
                                    hintText: '••••••••',
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.password],
                                    errorText: _passwordError,
                                    onSubmitted: (_) => _submit(session),
                                    suffixIcon: Icon(Icons.lock_outline_rounded, color: PsColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  const SizedBox(height: 16),
                                  AuthCoralSubmitButton(
                                    label: l10n.loginToPlayScout,
                                    loading: _loading,
                                    onPressed: _loading ? null : () => _submit(session),
                                  ),
                                  const SizedBox(height: 40),
                                  _OrDivider(theme: theme),
                                  const SizedBox(height: 40),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CompactSocial(
                                          onTap: _loading ? null : () => _socialGoogle(session),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const AuthGoogleLogo(size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.googleShort,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: PsColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _CompactSocial(
                                          onTap: _loading ? null : () => _socialApple(session),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AuthAppleLogo(size: 20, color: PsColors.onSurface),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.appleShort,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: PsColors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        l10n.newToPlayScout,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: PsColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.push(PsRoutes.authRegister),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 32),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          l10n.joinUs,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: PsColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _LoginFooter(theme: theme),
        ],
      ),
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFEFDF1).withValues(alpha: 0.82),
          border: Border(
            bottom: BorderSide(color: PsColors.outlineVariant.withValues(alpha: 0.2)),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: PsColors.primary,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).appTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: PsColors.primary,
                    ),
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

class _BlobDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -48,
          left: -48,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                size: const Size(256, 256),
                painter: _OrganicBlobPainter(color: const Color(0xFF327053)),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                size: const Size(384, 384),
                painter: _OrganicBlobPainter(color: const Color(0xFF955419)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrganicBlobPainter extends CustomPainter {
  _OrganicBlobPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height))
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(height: 1, color: PsColors.outlineVariant.withValues(alpha: 0.2)),
        DecoratedBox(
          decoration: BoxDecoration(color: PsColors.surfaceContainerLowest),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context).orContinueWith,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                fontSize: 11,
                color: PsColors.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactSocial extends StatelessWidget {
  const _CompactSocial({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PsColors.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: child,
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.nature_rounded, size: 40, color: PsColors.primary),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: PsColors.primary,
                          height: 1,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).outdoorDiscovery,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w800,
                          color: PsColors.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 96, height: 4, decoration: BoxDecoration(color: PsColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99))),
                  const SizedBox(width: 48),
                  Container(width: 96, height: 4, decoration: BoxDecoration(color: PsColors.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99))),
                  const SizedBox(width: 48),
                  Container(width: 96, height: 4, decoration: BoxDecoration(color: PsColors.tertiary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
