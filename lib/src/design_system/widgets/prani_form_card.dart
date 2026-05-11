import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// [PraniPremiumCard] with standard inner padding for dense BN forms.
class PraniFormCard extends StatelessWidget {
  const PraniFormCard({
    super.key,
    required this.child,
    this.margin,
    this.cardPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;

  /// When null, uses [PraniFormTokens.cardPadding] on all sides.
  final EdgeInsetsGeometry? cardPadding;

  @override
  Widget build(BuildContext context) {
    return PraniPremiumCard(
      margin: margin,
      padding: cardPadding ?? const EdgeInsets.all(PraniFormTokens.cardPadding),
      child: child,
    );
  }
}
