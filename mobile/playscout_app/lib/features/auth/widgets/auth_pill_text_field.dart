import 'package:flutter/material.dart';

import '../../../design_system/design_tokens.dart';

/// Stitch-style pill field: filled surface container, no border, focus ring.
class AuthPillTextField extends StatelessWidget {
  const AuthPillTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.autofillHints,
    this.enabled = true,
    this.leadingIconInside = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool leadingIconInside;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: PsColors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: PsColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 8,
        filled: true,
        fillColor: leadingIconInside ? PsColors.surfaceContainerLow : PsColors.surfaceContainer,
        contentPadding: EdgeInsets.fromLTRB(
          leadingIconInside ? 48 : 20,
          16,
          suffixIcon != null ? 44 : 20,
          16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: PsColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: PsColors.error.withValues(alpha: 0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: PsColors.error, width: 2),
        ),
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: PsColors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
    );

    Widget inner = field;
    if (leadingIconInside && prefixIcon != null) {
      inner = Stack(
        alignment: Alignment.centerLeft,
        children: [
          field,
          Positioned(
            left: 16,
            child: Icon(prefixIcon, color: PsColors.outlineVariant, size: 22),
          ),
        ],
      );
    } else if (suffixIcon != null) {
      inner = Stack(
        alignment: Alignment.centerRight,
        children: [
          field,
          Positioned(right: 20, child: suffixIcon!),
        ],
      );
    }

    if (label == null) {
      return inner;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: PsColors.onSurfaceVariant,
            ),
          ),
        ),
        inner,
      ],
    );
  }
}
