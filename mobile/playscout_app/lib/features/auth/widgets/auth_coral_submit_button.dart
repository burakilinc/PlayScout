import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch primary CTA on auth (`error-container` / `on-error-container`).
class AuthCoralSubmitButton extends StatelessWidget {
  const AuthCoralSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: PsColors.errorContainer,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      shadowColor: PsColors.errorContainer.withValues(alpha: 0.2),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.white24,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: PsColors.errorContainer.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: PsColors.onErrorContainer,
                      ),
                    )
                  : Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: PsColors.onErrorContainer,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
