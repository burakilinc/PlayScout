import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_tokens.dart';
import 'filter_options_controller.dart';
import 'models/venue_nearby_criteria.dart';
import 'widgets/filter_options_age_section.dart';
import 'widgets/filter_options_amenities_grid.dart';
import 'widgets/filter_options_distance_section.dart';
import 'widgets/filter_options_drag_handle.dart';
import 'widgets/filter_options_environment_section.dart';
import 'widgets/filter_options_header.dart';
import 'widgets/filter_options_sticky_actions.dart';
import 'widgets/filter_options_trust_safety_section.dart';

/// Stitch “Filter Options” bottom sheet as a full-screen route (`/filter`).
class FilterOptionsScreen extends StatefulWidget {
  const FilterOptionsScreen({
    super.key,
    this.initialCriteria,
  });

  final VenueNearbyCriteria? initialCriteria;

  @override
  State<FilterOptionsScreen> createState() => _FilterOptionsScreenState();
}

class _FilterOptionsScreenState extends State<FilterOptionsScreen> {
  late final FilterOptionsController _controller = FilterOptionsController(
    initial: widget.initialCriteria,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final sheetH = (h * 0.92).clamp(400.0, 813.0);

    return Scaffold(
      backgroundColor: PsColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Material(
                  elevation: 16,
                  shadowColor: Colors.black.withValues(alpha: 0.12),
                  color: PsColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(PsRadii.xl)),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: sheetH,
                    child: Column(
                        children: [
                          FilterOptionsHeader(onClose: () => context.pop()),
                          Container(height: 1, color: PsColors.surfaceContainer.withValues(alpha: 0.5)),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ListenableBuilder(
                                  listenable: _controller,
                                  builder: (context, _) {
                                    final c = _controller.criteria;
                                    return SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        PsSpacing.lg,
                                        PsSpacing.md,
                                        PsSpacing.lg,
                                        120,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const FilterOptionsDragHandle(),
                                          const SizedBox(height: PsSpacing.xl),
                                          FilterOptionsDistanceSection(
                                            radiusKm: c.radiusKm,
                                            onChanged: _controller.setRadiusKm,
                                          ),
                                          const SizedBox(height: PsSpacing.xl),
                                          FilterOptionsEnvironmentSection(
                                            environment: c.environment,
                                            onSelect: _controller.setEnvironment,
                                          ),
                                          const SizedBox(height: PsSpacing.xl),
                                          FilterOptionsAgeSection(
                                            selected: c.ageBand,
                                            onSelect: _controller.selectAgeBand,
                                          ),
                                          const SizedBox(height: PsSpacing.xl),
                                          FilterOptionsAmenitiesGrid(
                                            selectedIds: c.amenityFeatureTypeIds,
                                            onToggle: _controller.toggleAmenity,
                                          ),
                                          const SizedBox(height: PsSpacing.xl),
                                          FilterOptionsTrustSafetySection(
                                            playSupervisor: c.requirePlaySupervisor,
                                            childDropOff: c.requireChildDropOff,
                                            onToggleSupervisor: _controller.togglePlaySupervisor,
                                            onToggleDropOff: _controller.toggleChildDropOff,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: SafeArea(
                                    top: false,
                                    child: FilterOptionsStickyActions(
                                      onReset: () => _controller.reset(),
                                      onApply: () => context.pop(_controller.criteria),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
