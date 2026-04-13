import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../../design_system/design_tokens.dart';

class InteractiveMapListCta extends StatelessWidget {
  const InteractiveMapListCta({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).listView,
        child: Material(
          color: PsColors.primary,
          elevation: 12,
          shadowColor: const Color(0xFF36392B).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(9999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PsSpacing.lg, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_rounded, color: PsColors.onPrimary, size: 22),
                  const SizedBox(width: PsSpacing.sm),
                  Text(
                    AppLocalizations.of(context).listView,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: PsColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
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
