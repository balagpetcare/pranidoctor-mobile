import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';

/// Compact filter controls for provider list APIs.
class ProviderFilterPanel extends StatelessWidget {
  const ProviderFilterPanel({
    super.key,
    required this.query,
    required this.onQueryChanged,
    this.showOnlineConsultation = true,
  });

  static const Set<String> _knownAreaSlugs = {'ashulia-union-area'};

  final ProviderListQuery query;
  final void Function(ProviderListQuery next) onQueryChanged;
  final bool showOnlineConsultation;

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

  Widget _dropdown<T>(
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
        DropdownButton<T?>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: const Text('ফিল্টার'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _dropdown<String?>(
            context,
            label: 'এলাকা (ডেমো স্লাগ)',
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
          const SizedBox(height: 12),
          _dropdown<AnimalType?>(
            context,
            label: 'পশুর ধরন',
            value: query.animalType,
            items: [
              const DropdownMenuItem(value: null, child: Text('সব')),
              ...AnimalType.values.map(
                (t) => DropdownMenuItem(value: t, child: Text(_animalLabel(t))),
              ),
            ],
            onChanged: (v) {
              onQueryChanged(
                query.withFilters(animalType: v, clearAnimalType: v == null),
              );
            },
          ),
          const SizedBox(height: 12),
          _dropdown<bool?>(
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
          const SizedBox(height: 12),
          _dropdown<bool?>(
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
            const SizedBox(height: 12),
            _dropdown<bool?>(
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                onQueryChanged(ProviderListQuery.initial);
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('ফিল্টার মুছুন'),
            ),
          ),
        ],
      ),
    );
  }
}
