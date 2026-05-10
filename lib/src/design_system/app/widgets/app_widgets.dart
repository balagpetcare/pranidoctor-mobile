/// P01 widget aliases and shared components (import this file for App-layer names).
library;

export '../../widgets/prani_empty_state_card.dart';
export '../../widgets/prani_premium_card.dart';
export '../../widgets/prani_primary_cta_button.dart';
export '../../widgets/prani_safe_page.dart';
export '../../widgets/prani_section_header.dart';
export 'app_icon_badge.dart';
export 'secondary_action_button.dart';

import '../../widgets/prani_empty_state_card.dart';
import '../../widgets/prani_premium_card.dart';
import '../../widgets/prani_primary_cta_button.dart';
import '../../widgets/prani_safe_page.dart';
import '../../widgets/prani_section_header.dart';

typedef AppPageScaffold = PraniSafePage;
typedef AppBottomNavContentPadding = PraniBottomNavContentPadding;
typedef PremiumCard = PraniPremiumCard;
typedef SectionHeader = PraniSectionHeader;
typedef PrimaryActionButton = PraniPrimaryCtaButton;
typedef EmptyStateCard = PraniEmptyStateCard;
