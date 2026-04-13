import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../design_system/design_tokens.dart';
import 'stitch_auth_assets.dart';
import 'widgets/auth_coral_submit_button.dart';
import 'widgets/auth_pill_text_field.dart';

/// Stitch `forgot_password` — top bar, glass card, simulated reset (no API).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PsColors.surface,
      body: Column(
        children: [
          _ForgotTopBar(onBack: () => context.pop()),
          Expanded(
            child: Stack(
              children: [
                const ColoredBox(color: Color(0xFFE8F4F0)),
                Positioned(
                  top: -48,
                  left: -48,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.network(
                          StitchAuthAssets.forgotTreeIllustration,
                          width: 256,
                          height: 256,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -96,
                  right: -48,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.network(
                          StitchAuthAssets.forgotSkyIllustration,
                          width: 320,
                          height: 320,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: PsColors.surfaceContainerLowest.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(PsRadii.lg),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              boxShadow: PsColors.parkShadow(),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(PsRadii.lg),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                                child: Column(
                                  children: [
                                    DecoratedBox(
                                      decoration: const BoxDecoration(
                                        color: PsColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(Icons.lock_reset_rounded, size: 40, color: PsColors.primary),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      l10n.forgotTitle,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: PsColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.forgotLead,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: PsColors.onSurfaceVariant,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                                          child: Text(
                                            l10n.parentEmail,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                              color: PsColors.outlineVariant,
                                            ),
                                          ),
                                        ),
                                        AuthPillTextField(
                                          controller: _email,
                                          hintText: 'hello@example.com',
                                          keyboardType: TextInputType.emailAddress,
                                          leadingIconInside: true,
                                          prefixIcon: Icons.mail_outline_rounded,
                                          enabled: !_success,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    AuthCoralSubmitButton(
                                      label: l10n.resetPassword,
                                      loading: _loading,
                                      onPressed: _success ? null : () => _submit(),
                                    ),
                                    const SizedBox(height: 32),
                                    Divider(height: 1, color: PsColors.outlineVariant.withValues(alpha: 0.1)),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          l10n.rememberedIt,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: PsColors.onSurfaceVariant,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => context.pop(),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 28),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            l10n.goBackToLogin,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: PsColors.primary,
                                              fontWeight: FontWeight.w800,
                                              decoration: TextDecoration.underline,
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
                          if (_success) ...[
                            const SizedBox(height: 32),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: PsColors.secondaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(PsRadii.sm),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: PsColors.secondary, size: 22),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        l10n.forgotResetInfo,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: PsColors.onSecondaryContainer,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotTopBar extends StatelessWidget {
  const _ForgotTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5E4).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: PsColors.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: PsColors.primary,
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).appTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: PsColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
