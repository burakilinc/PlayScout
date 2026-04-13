import 'package:flutter/material.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import 'locale_scope.dart';

const List<({String code, String label})> playScoutSupportedLanguages = [
  (code: 'tr', label: 'Turkce'),
  (code: 'en', label: 'English'),
  (code: 'ja', label: '日本語'),
  (code: 'zh', label: '中文'),
  (code: 'de', label: 'Deutsch'),
  (code: 'fr', label: 'Francais'),
  (code: 'ko', label: '한국어'),
  (code: 'pt', label: 'Portugues'),
  (code: 'es', label: 'Espanol'),
  (code: 'ru', label: 'Русский'),
  (code: 'ar', label: 'العربية'),
  (code: 'hi', label: 'हिन्दी'),
  (code: 'it', label: 'Italiano'),
];

Future<void> showLanguagePickerSheet(BuildContext context) async {
  final localeController = LocaleScope.of(context);
  final selectedCode = localeController.locale?.languageCode;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(l10n.languageTitle),
              subtitle: Text(
                l10n.languageSubtitle,
              ),
            ),
            ListTile(
              leading: Icon(
                selectedCode == null
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
              title: Text(l10n.useDeviceLanguage),
              onTap: () async {
                await localeController.useDeviceDefault();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            for (final entry in playScoutSupportedLanguages)
              ListTile(
                leading: Icon(
                  selectedCode == entry.code
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(entry.label),
                onTap: () async {
                  await localeController.setLanguageCode(entry.code);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
      );
    },
  );
}

String currentLanguageLabel(BuildContext context) {
  final c = LocaleScope.of(context);
  final code = c.locale?.languageCode;
  final l10n = AppLocalizations.of(context);
  if (code == null) return l10n.deviceLanguageLabel;
  final match = playScoutSupportedLanguages.where((e) => e.code == code);
  if (match.isEmpty) return code.toUpperCase();
  return match.first.label;
}
