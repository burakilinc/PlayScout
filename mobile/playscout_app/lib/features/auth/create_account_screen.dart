import 'package:flutter/gestures.dart';
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

/// Stitch `create_account` — header, card form + terms, social row (Google + Apple), footer.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _terms = false;
  bool _loading = false;
  String? _banner;
  String? _nameErr;
  String? _emailErr;
  String? _pwErr;
  String? _confirmErr;

  late final TapGestureRecognizer _termsLinkTap;
  late final TapGestureRecognizer _privacyLinkTap;

  @override
  void initState() {
    super.initState();
    _termsLinkTap = TapGestureRecognizer()
      ..onTap = () => _snack(AppLocalizations.of(context).termsLinkSoon);
    _privacyLinkTap = TapGestureRecognizer()
      ..onTap = () => _snack(AppLocalizations.of(context).privacyLinkSoon);
  }

  @override
  void dispose() {
    _termsLinkTap.dispose();
    _privacyLinkTap.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _pwRuleOk(String p) {
    if (p.length < 8 || p.length > 128) return false;
    if (!RegExp(r'[A-Z]').hasMatch(p)) return false;
    if (!RegExp(r'[a-z]').hasMatch(p)) return false;
    if (!RegExp(r'[0-9]').hasMatch(p)) return false;
    return true;
  }

  Future<void> _snack(String text) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit(AuthSession session) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _nameErr = _emailErr = _pwErr = _confirmErr = null;
    });
    if (!_terms) {
      setState(() => _banner = l10n.acceptTermsRequired);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _confirmErr = l10n.passwordsDoNotMatch);
      return;
    }
    if (!_pwRuleOk(_password.text)) {
      setState(() {
        _pwErr = l10n.passwordRulesError;
      });
      return;
    }

    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    setState(() => _loading = true);
    try {
      final tokens = await session.register(
        email: _email.text.trim(),
        password: _password.text,
        displayName: _name.text.trim(),
      );
      await session.applyTokens(tokens);
      final d = await session.dispatchPendingIntent(
        router,
        onFavoriteResume: session.hasMemberSession ? (id) => fav.addFavorite(venueId: id) : null,
      );
      if (!mounted) return;
      if (!d.navigated) router.go(PsRoutes.home);
    } catch (e) {
      if (!mounted) return;
      if (e is AuthApiValidationException) {
        setState(() {
          _emailErr = e.firstMessageFor('Email') ?? e.firstMessageFor('email');
          _pwErr = e.firstMessageFor('Password') ?? e.firstMessageFor('password');
          _nameErr = e.firstMessageFor('DisplayName') ?? e.firstMessageFor('displayName');
          if (_emailErr == null && _pwErr == null && _nameErr == null) {
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

  Future<void> _google(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apple(AuthSession session) async {
    final router = GoRouter.of(context);
    final fav = FavoritesScope.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AuthScope.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: PsColors.surface,
      body: Column(
        children: [
          _CreateHeader(
            wide: wide,
            onLogin: () => context.push(PsRoutes.authLogin),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: -48,
                  right: -48,
                  child: IgnorePointer(
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PsColors.secondaryContainer.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -96,
                  left: -96,
                  child: IgnorePointer(
                    child: Container(
                      width: 384,
                      height: 384,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PsColors.primaryContainer.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 576),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PsColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(PsRadii.lg),
                          border: Border.all(color: PsColors.outlineVariant.withValues(alpha: 0.15)),
                          boxShadow: PsColors.parkShadow(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                          child: Column(
                            crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                                            softWrap: true,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: PsColors.onSecondaryContainer,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                l10n.joinPlayScout,
                                textAlign: wide ? TextAlign.start : TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: PsColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.createAccountLead,
                                textAlign: wide ? TextAlign.start : TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: PsColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AuthPillTextField(
                                        controller: _name,
                                        label: l10n.fullName,
                                        hintText: 'John Doe',
                                        leadingIconInside: true,
                                        prefixIcon: Icons.person_outline_rounded,
                                        errorText: _nameErr,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: AuthPillTextField(
                                        controller: _email,
                                        label: l10n.emailAddress,
                                        hintText: 'name@example.com',
                                        keyboardType: TextInputType.emailAddress,
                                        leadingIconInside: true,
                                        prefixIcon: Icons.mail_outline_rounded,
                                        errorText: _emailErr,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                AuthPillTextField(
                                  controller: _name,
                                  label: l10n.fullName,
                                  hintText: 'John Doe',
                                  leadingIconInside: true,
                                  prefixIcon: Icons.person_outline_rounded,
                                  errorText: _nameErr,
                                ),
                                const SizedBox(height: 24),
                                AuthPillTextField(
                                  controller: _email,
                                  label: l10n.emailAddress,
                                  hintText: 'name@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                  leadingIconInside: true,
                                  prefixIcon: Icons.mail_outline_rounded,
                                  errorText: _emailErr,
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AuthPillTextField(
                                        controller: _password,
                                        label: l10n.password,
                                        hintText: '••••••••',
                                        obscureText: true,
                                        leadingIconInside: true,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        errorText: _pwErr,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: AuthPillTextField(
                                        controller: _confirm,
                                        label: l10n.confirmPassword,
                                        hintText: '••••••••',
                                        obscureText: true,
                                        leadingIconInside: true,
                                        prefixIcon: Icons.lock_reset_rounded,
                                        errorText: _confirmErr,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                AuthPillTextField(
                                  controller: _password,
                                  label: l10n.password,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  leadingIconInside: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  errorText: _pwErr,
                                ),
                                const SizedBox(height: 24),
                                AuthPillTextField(
                                  controller: _confirm,
                                  label: l10n.confirmPassword,
                                  hintText: '••••••••',
                                  obscureText: true,
                                  leadingIconInside: true,
                                  prefixIcon: Icons.lock_reset_rounded,
                                  errorText: _confirmErr,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _terms,
                                      side: const BorderSide(color: PsColors.outlineVariant),
                                      onChanged: (v) => setState(() => _terms = v ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: PsColors.onSurfaceVariant,
                                          height: 1.35,
                                        ),
                                        children: [
                                          TextSpan(text: l10n.iAgreeToThe),
                                          TextSpan(
                                            text: l10n.legalTerms,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: PsColors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: _termsLinkTap,
                                          ),
                                          TextSpan(text: l10n.andText),
                                          TextSpan(
                                            text: l10n.legalPrivacy,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: PsColors.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: _privacyLinkTap,
                                          ),
                                          TextSpan(text: l10n.dotText),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AuthCoralSubmitButton(
                                label: l10n.createMyAccount,
                                loading: _loading,
                                onPressed: _loading ? null : () => _submit(session),
                              ),
                              const SizedBox(height: 48),
                              _OrDivider(theme: theme),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialPill(
                                      onTap: _loading ? null : () => _google(session),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const AuthGoogleLogo(size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            l10n.googleShort,
                                            style: theme.textTheme.titleSmall?.copyWith(
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
                                    child: _SocialPill(
                                      onTap: _loading ? null : () => _apple(session),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AuthAppleLogo(size: 20, color: PsColors.onSurface),
                                          const SizedBox(width: 12),
                                          Text(
                                            l10n.appleShort,
                                            style: theme.textTheme.titleSmall?.copyWith(
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _CreateFooter(theme: theme),
        ],
      ),
    );
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader({required this.wide, required this.onLogin});

  final bool wide;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: PsColors.primary,
                  letterSpacing: -0.25,
                ),
              ),
            ),
            if (wide) ...[
              Text(
                AppLocalizations.of(context).alreadyHaveAccount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PsColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: PsColors.primary,
                  side: BorderSide.none,
                  backgroundColor: Colors.transparent,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text(
                  AppLocalizations.of(context).logIn,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PsColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(height: 1, color: PsColors.outlineVariant.withValues(alpha: 0.3))),
        Padding(
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
        Expanded(child: Divider(height: 1, color: PsColors.outlineVariant.withValues(alpha: 0.3))),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({required this.child, required this.onTap});

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
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: child,
        ),
      ),
    );
  }
}

class _CreateFooter extends StatelessWidget {
  const _CreateFooter({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: LayoutBuilder(
          builder: (context, c) {
            final row = c.maxWidth > 600;
            final links = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).privacy, style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant.withValues(alpha: 0.6))),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).terms, style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant.withValues(alpha: 0.6))),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).cookies, style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant.withValues(alpha: 0.6))),
                ),
              ],
            );
            if (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).copyrightLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PsColors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  links,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).copyrightLine,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PsColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                links,
              ],
            );
          },
        ),
      ),
    );
  }
}
