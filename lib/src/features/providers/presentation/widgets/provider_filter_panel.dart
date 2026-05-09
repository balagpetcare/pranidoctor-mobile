import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';

/// Compact filter controls for provider list APIs.
class ProviderFilterPanel extends StatelessWidget {
  const ProviderFilterPanel({
    super.key,
    required this.query,
    required this.onQueryChanged,
    this.showOnlineConsultation = true,
    this.horizontalPadding = 16,
  });

  static const Set<String> _knownAreaSlugs = {'ashulia-union-area'};

  final ProviderListQuery query;
  final void Function(ProviderListQuery next) onQueryChanged;
  final bool showOnlineConsultation;

  /// Horizontal inset for the filter [Card] (match screen padding).
  final double horizontalPadding;

  static String _animalLabel(AnimalType t) {
    switch (t) {
      case AnimalType.CATTLE:
        return 'গরু';
      case AnimalType.GOAT:
        return 'ছাগল';
      case AnimalType.POULTRY:
        return 'হাঁস–মুরগি';
      case AnimalType.DOG:
        return 'কুকুর';
      case AnimalType.CAT:
        return 'বিড়াল';
      case AnimalType.OTHER:
        return 'অন্যান্য';
    }
  }

  static String? _safeAreaSlug(String? slug) {
    if (slug == null || slug.isEmpty) return null;
    return _knownAreaSlugs.contains(slug) ? slug : null;
  }

  static String _filterSummary(ProviderListQuery q) {
    if (!q.hasNonDefaultDoctorFilters) return 'কোনো ফিল্টার নেই';
    final parts = <String>[];
    final slug = _safeAreaSlug(q.areaSlug);
    if (slug != null) parts.add('এলাকা');
    if (q.animalType != null) parts.add(_animalLabel(q.animalType!));
    if (q.homeVisit == true) parts.add('হোম ভিজিট');
    if (q.homeVisit == false) parts.add('হোম ভিজিট: না');
    if (q.emergency == true) parts.add('জরুরি');
    if (q.emergency == false) parts.add('জরুরি: না');
    if (q.onlineConsultation == true) parts.add('অনলাইন');
    if (q.onlineConsultation == false) parts.add('অনলাইন: না');
    return parts.join(' · ');
  }

  Widget _dropdownField<T>(
    BuildContext context, {
    required String label,
    required T? value,
    required List<DropdownMenuItem<T?>> items,
    required void Function(T? v) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              isExpanded: true,
              isDense: true,
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFilters = query.hasNonDefaultDoctorFilters;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 0),
      child: Material(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PraniRadii.lg),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            maintainState: true,
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            title: Text(
              'ফিল্টার',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _filterSummary(query),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            children: [
              _dropdownField<String?>(
                context,
                label: 'এলাকা',
                value: ProviderFilterPanel._safeAreaSlug(query.areaSlug),
                items: const [
                  DropdownMenuItem(value: null, child: Text('সব এলাকা')),
                  DropdownMenuItem(
                    value: 'ashulia-union-area',
                    child: Text('আশুলিয়া ইউনিয়ন'),
                  ),
                ],
                onChanged: (v) {
                  onQueryChanged(
                    query.withFilters(
                      areaSlug: v,
                      clearAreaSlug: v == null,
                      clearAreaId: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _dropdownField<AnimalType?>(
                context,
                label: 'পশুর ধরন',
                value: query.animalType,
                items: [
                  const DropdownMenuItem(value: null, child: Text('সব')),
                  ...AnimalType.values.map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_animalLabel(t)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  onQueryChanged(
                    query.withFilters(
                      animalType: v,
                      clearAnimalType: v == null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _dropdownField<bool?>(
                context,
                label: 'হোম ভিজিট',
                value: query.homeVisit,
                items: const [
                  DropdownMenuItem(value: null, child: Text('সব')),
                  DropdownMenuItem(value: true, child: Text('হ্যাঁ')),
                  DropdownMenuItem(value: false, child: Text('না')),
                ],
                onChanged: (v) {
                  onQueryChanged(
                    query.withFilters(homeVisit: v, clearHomeVisit: v == null),
                  );
                },
              ),
              const SizedBox(height: 10),
              _dropdownField<bool?>(
                context,
                label: 'জরুরি সেবা',
                value: query.emergency,
                items: const [
                  DropdownMenuItem(value: null, child: Text('সব')),
                  DropdownMenuItem(value: true, child: Text('হ্যাঁ')),
                  DropdownMenuItem(value: false, child: Text('না')),
                ],
                onChanged: (v) {
                  onQueryChanged(
                    query.withFilters(emergency: v, clearEmergency: v == null),
                  );
                },
              ),
              if (showOnlineConsultation) ...[
                const SizedBox(height: 10),
                _dropdownField<bool?>(
                  context,
                  label: 'অনলাইন কনসালটেশন',
                  value: query.onlineConsultation,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('সব')),
                    DropdownMenuItem(value: true, child: Text('হ্যাঁ')),
                    DropdownMenuItem(value: false, child: Text('না')),
                  ],
                  onChanged: (v) {
                    onQueryChanged(
                      query.withFilters(
                        onlineConsultation: v,
                        clearOnlineConsultation: v == null,
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: hasFilters
                      ? () {
                          onQueryChanged(ProviderListQuery.initial);
                        }
                      : null,
                  icon: const Icon(Icons.clear_all, size: 20),
                  label: const Text('ফিল্টার মুছুন'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
