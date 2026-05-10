import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/widgets/prani_app_search_bar.dart';
import 'package:pranidoctor_mobile/src/features/home/presentation/home_layout_constants.dart';

/// Search + filter affordances (non-editable bar; parent handles taps).
class HomeSearchCard extends StatelessWidget {
  const HomeSearchCard({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return PraniAppSearchBar(
      hintText: 'ডাক্তার, সেবা, রোগ খুঁজুন...',
      borderRadius: HomeLayout.cardRadius,
      onSearchTap: onSearchTap,
      onFilterTap: onFilterTap,
    );
  }
}
