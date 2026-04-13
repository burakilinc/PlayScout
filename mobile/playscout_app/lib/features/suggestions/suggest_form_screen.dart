import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playscout_app/l10n/app_localizations.dart';

import '../../app/auth_scope.dart';
import '../../app/member_api_scope.dart';
import '../../app/router.dart';
import '../../design_system/design_tokens.dart';
import '../auth/models/pending_auth_intent.dart';
import '../auth/protected_member_action.dart';
import 'data/suggestions_repository.dart';

/// Full-member POST `/suggestions` form.
class SuggestFormScreen extends StatefulWidget {
  const SuggestFormScreen({super.key});

  @override
  State<SuggestFormScreen> createState() => _SuggestFormScreenState();
}

class _SuggestFormScreenState extends State<SuggestFormScreen> {
  final _name = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _label = TextEditingController();
  final _description = TextEditingController();
  final _minAge = TextEditingController();
  final _maxAge = TextEditingController();

  int _category = 1;
  bool _supervisor = false;
  bool _dropOff = false;
  final Set<int> _amenities = {};
  bool _submitting = false;
  String? _banner;
  String? _nameErr;
  String? _locationErr;
  String? _descriptionErr;
  String? _ageErr;

  static const _categories = <int>[1, 2, 3, 4, 5, 99];

  /// VenueFeatureType values (excluding 1–2 handled by trust toggles when selected).
  static const _extraAmenityChips = <int>[3, 4, 5, 6, 7, 8, 9, 10, 11];

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lng.dispose();
    _label.dispose();
    _description.dispose();
    _minAge.dispose();
    _maxAge.dispose();
    super.dispose();
  }

  void _syncTrustAmenities() {
    if (!_supervisor) _amenities.remove(1);
    if (!_dropOff) _amenities.remove(2);
  }

  bool _validate() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _banner = null;
      _nameErr = _locationErr = _descriptionErr = _ageErr = null;
    });

    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _nameErr = l10n.suggestNameMin);
      return false;
    }
    if (!RegExp(r'[A-Za-z0-9]').hasMatch(name)) {
      setState(() => _nameErr = l10n.suggestNameAlphanumeric);
      return false;
    }

    final latT = _lat.text.trim();
    final lngT = _lng.text.trim();
    double? la;
    double? lo;
    if (latT.isNotEmpty || lngT.isNotEmpty) {
      la = double.tryParse(latT);
      lo = double.tryParse(lngT);
      if (la == null || lo == null) {
        setState(() => _locationErr = l10n.suggestLocationNumbersInvalid);
        return false;
      }
      if (la < -90 || la > 90 || lo < -180 || lo > 180) {
        setState(() => _locationErr = l10n.suggestLocationOutOfRange);
        return false;
      }
    }

    final lab = _label.text.trim();
    final hasCoords = la != null && lo != null;
    final hasLabel = lab.length >= 5;
    if (!hasCoords && !hasLabel) {
      setState(() => _locationErr = l10n.suggestLocationEitherOr);
      return false;
    }

    final desc = _description.text.trim();
    if (desc.isNotEmpty && desc.length < 10) {
      setState(() => _descriptionErr = l10n.suggestDetailsMinLen);
      return false;
    }

    int? minM;
    int? maxM;
    if (_minAge.text.trim().isNotEmpty) {
      minM = int.tryParse(_minAge.text.trim());
      if (minM == null || minM < 0 || minM > 216) {
        setState(() => _ageErr = l10n.suggestMinAgeRange);
        return false;
      }
    }
    if (_maxAge.text.trim().isNotEmpty) {
      maxM = int.tryParse(_maxAge.text.trim());
      if (maxM == null || maxM < 0 || maxM > 216) {
        setState(() => _ageErr = l10n.suggestMaxAgeRange);
        return false;
      }
    }
    if (minM != null && maxM != null && minM > maxM) {
      setState(() => _ageErr = l10n.suggestMinGreaterMax);
      return false;
    }

    for (final a in _amenities) {
      if (a == 1 && !_supervisor) {
        setState(() => _banner = l10n.suggestSupervisorAmenityRequires);
        return false;
      }
      if (a == 2 && !_dropOff) {
        setState(() => _banner = l10n.suggestDropoffAmenityRequires);
        return false;
      }
    }

    return true;
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    if (!auth.hasMemberSession) {
      await playScoutRequireFullMember(
        context,
        resumeIfGuest: PendingAuthIntent.suggestPlaceForm,
        whenMember: () async {
          if (context.mounted) await _submit();
        },
      );
      return;
    }

    if (!_validate()) return;

    final name = _name.text.trim();
    final latT = _lat.text.trim();
    final lngT = _lng.text.trim();
    final hasCoords = latT.isNotEmpty && lngT.isNotEmpty;
    final la = hasCoords ? double.tryParse(latT) : null;
    final lo = hasCoords ? double.tryParse(lngT) : null;
    final lab = _label.text.trim();
    final desc = _description.text.trim();

    int? minM;
    int? maxM;
    if (_minAge.text.trim().isNotEmpty) minM = int.tryParse(_minAge.text.trim());
    if (_maxAge.text.trim().isNotEmpty) maxM = int.tryParse(_maxAge.text.trim());

    final amenityList = _amenities.toList()..sort();
    final payload = CreateSuggestionPayload(
      name: name,
      category: _category,
      latitude: la,
      longitude: lo,
      locationLabel: lab.isEmpty ? null : lab,
      description: desc.isEmpty ? null : desc,
      minAgeMonths: minM,
      maxAgeMonths: maxM,
      hasPlaySupervisor: _supervisor,
      allowsChildDropOff: _dropOff,
      optionalAmenities: amenityList.isEmpty ? null : amenityList,
    );

    setState(() => _submitting = true);
    try {
      final res = await MemberApiScope.of(context).suggestions.create(payload);
      if (!mounted) return;
      context.go(PsRoutes.suggestSuccess, extra: res);
    } on SuggestionsValidationException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _nameErr = e.firstForField('name');
        _locationErr = e.firstForField('locationLabel') ?? e.firstForField('latitude') ?? e.firstForField('longitude');
        _descriptionErr = e.firstForField('description');
        _ageErr = e.firstForField('minAgeMonths') ?? e.firstForField('maxAgeMonths');
        if (_nameErr == null &&
            _locationErr == null &&
            _descriptionErr == null &&
            _ageErr == null) {
          final combined = e.combinedMessage();
          _banner = combined.isEmpty ? l10n.suggestValidationGeneric : combined;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _banner = AppLocalizations.of(context).suggestCouldNotSend);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = AuthScope.of(context);
    final l10n = AppLocalizations.of(context);
    String categoryLabel(int id) => switch (id) {
          1 => l10n.indoorPlay,
          2 => l10n.outdoorPlay,
          3 => l10n.mixedIndoorOutdoor,
          4 => l10n.dropInCare,
          5 => l10n.familyCafeRestaurant,
          _ => l10n.other,
        };
    String amenityLabel(int id) => switch (id) {
          3 => l10n.indoor,
          4 => l10n.outdoor,
          5 => l10n.fenced,
          6 => l10n.shade,
          7 => l10n.sand,
          8 => l10n.strollerFriendly,
          9 => l10n.parking,
          10 => l10n.restrooms,
          _ => l10n.foodNearby,
        };

    if (!auth.hasMemberSession) {
      return Scaffold(
        backgroundColor: PsColors.background,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
          title: Text(l10n.suggestPlaceTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(PsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.signInFullAccountSuggest,
                style: theme.textTheme.bodyLarge?.copyWith(color: PsColors.onSurfaceVariant),
              ),
              const SizedBox(height: PsSpacing.xl),
              FilledButton(
                onPressed: () => playScoutRequireFullMember(
                  context,
                  resumeIfGuest: PendingAuthIntent.suggestPlaceForm,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.suggestPlaceTitle),
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: ListView(
          padding: const EdgeInsets.all(PsSpacing.lg),
          children: [
            if (_banner != null) ...[
              Text(_banner!, style: theme.textTheme.bodyMedium?.copyWith(color: PsColors.error)),
              const SizedBox(height: PsSpacing.lg),
            ],
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.placeName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                errorText: _nameErr,
              ),
            ),
            const SizedBox(height: PsSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: DropdownMenu<int>(
                key: ValueKey<int>(_category),
                initialSelection: _category,
                label: Text(l10n.category),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: [
                  for (final c in _categories)
                    DropdownMenuEntry(value: c, label: categoryLabel(c)),
                ],
                onSelected: (v) => setState(() => _category = v ?? 1),
              ),
            ),
            const SizedBox(height: PsSpacing.xl),
            Text(l10n.location, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: PsSpacing.sm),
            Text(
              l10n.locationHelp,
              style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant),
            ),
            const SizedBox(height: PsSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: l10n.latitude,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                    ),
                  ),
                ),
                const SizedBox(width: PsSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: l10n.longitude,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsSpacing.md),
            TextFormField(
              controller: _label,
              decoration: InputDecoration(
                labelText: l10n.locationLabelHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                errorText: _locationErr,
              ),
            ),
            const SizedBox(height: PsSpacing.xl),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: l10n.whyFamiliesLoveItOptional,
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                errorText: _descriptionErr,
              ),
            ),
            const SizedBox(height: PsSpacing.xl),
            Text(l10n.ageRangeMonthsOptional, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (_ageErr != null) ...[
              const SizedBox(height: PsSpacing.sm),
              Text(_ageErr!, style: theme.textTheme.bodySmall?.copyWith(color: PsColors.error)),
            ],
            const SizedBox(height: PsSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAge,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.minMonths,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                    ),
                  ),
                ),
                const SizedBox(width: PsSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _maxAge,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxMonths,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(PsRadii.sm)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsSpacing.lg),
            SwitchListTile(
              title: Text(l10n.playSupervisorOnSite),
              value: _supervisor,
              onChanged: (v) => setState(() {
                _supervisor = v;
                _syncTrustAmenities();
              }),
            ),
            SwitchListTile(
              title: Text(l10n.allowsSupervisedDropoff),
              value: _dropOff,
              onChanged: (v) => setState(() {
                _dropOff = v;
                _syncTrustAmenities();
              }),
            ),
            const SizedBox(height: PsSpacing.md),
            Text(l10n.optionalAmenities, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: PsSpacing.sm),
            Wrap(
              spacing: PsSpacing.sm,
              runSpacing: PsSpacing.sm,
              children: [
                FilterChip(
                  label: Text(l10n.playSupervisorShort),
                  selected: _amenities.contains(1),
                  onSelected: !_supervisor
                      ? null
                      : (s) => setState(() {
                            if (s) {
                              _amenities.add(1);
                            } else {
                              _amenities.remove(1);
                            }
                          }),
                ),
                FilterChip(
                  label: Text(l10n.dropoffAllowed),
                  selected: _amenities.contains(2),
                  onSelected: !_dropOff
                      ? null
                      : (s) => setState(() {
                            if (s) {
                              _amenities.add(2);
                            } else {
                              _amenities.remove(2);
                            }
                          }),
                ),
                for (final c in _extraAmenityChips)
                  FilterChip(
                    label: Text(amenityLabel(c)),
                    selected: _amenities.contains(c),
                    onSelected: (s) => setState(() {
                      if (s) {
                        _amenities.add(c);
                      } else {
                        _amenities.remove(c);
                      }
                    }),
                  ),
              ],
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
                  : Text(l10n.submitForReview),
            ),
            const SizedBox(height: PsSpacing.md),
            Text(
              l10n.suggestModerationNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: PsColors.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: PsSpacing.xl),
          ],
        ),
      ),
    );
  }
}
