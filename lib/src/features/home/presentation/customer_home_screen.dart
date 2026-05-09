import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screen_padding.dart';
import '../../../core/constants/pd_spacing.dart';
import '../../notifications/presentation/notifications_list_screen.dart';
import '../../service_requests/data/service_request_model.dart';
import '../../service_requests/presentation/booking_wizard_screen.dart';
import '../../service_requests/presentation/service_requests_list_screen.dart';
import '../../tutorials/presentation/tutorial_list_screen.dart';
import 'widgets/customer_emergency_cta_card.dart';
import 'widgets/customer_home_header.dart';
import 'widgets/customer_home_section_title.dart';
import 'widgets/customer_recent_request_card.dart';
import 'widgets/customer_service_action_card.dart';
import 'widgets/customer_shortcut_card.dart';

/// Bengali-first customer dashboard (হোম ট্যাব).
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({
    super.key,
    required this.onOpenAnimalsTab,
    required this.onOpenRequestsTab,
  });

  final VoidCallback onOpenAnimalsTab;
  final VoidCallback onOpenRequestsTab;

  String _bookingWithPreset(ServiceRequestType type) {
    return '${BookingWizardScreen.routePath}?preset=${type.name}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = pdScreenPadding(context);
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: pad.copyWith(top: PdSpacing.md, bottom: PdSpacing.xl),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomerHomeHeader(
                          onNotificationsTap: () =>
                              context.push(NotificationsListScreen.routePath),
                        ),
                        const SizedBox(height: PdSpacing.xl),
                        CustomerEmergencyCtaCard(
                          onPressed: () => context.push(
                            _bookingWithPreset(
                              ServiceRequestType.EMERGENCY_DOCTOR,
                            ),
                          ),
                        ),
                        const SizedBox(height: PdSpacing.xl),
                        const CustomerHomeSectionTitle(
                          title: 'সেবাসমূহ',
                          subtitle: 'প্রয়োজন অনুযায়ী নির্বাচন করুন',
                        ),
                        CustomerServiceActionCard(
                          icon: Icons.medical_services_outlined,
                          title: 'ডাক্তার — বাড়িতে পরিদর্শন',
                          subtitle: 'বাড়িতে গিয়ে চিকিৎসা — অনুরোধ জমা দিন।',
                          onTap: () => context.push(
                            _bookingWithPreset(
                              ServiceRequestType.DOCTOR_HOME_VISIT,
                            ),
                          ),
                        ),
                        const SizedBox(height: PdSpacing.sm),
                        CustomerServiceActionCard(
                          icon: Icons.smart_toy_outlined,
                          title: 'AI টেকনিশিয়ান',
                          subtitle:
                              'এআই টেকনিশিয়ান সেবার অনুরোধ জমা দিন বা পরবর্তীতে প্রদানকারী বেছে নিন।',
                          onTap: () => context.push(
                            _bookingWithPreset(ServiceRequestType.AI_SERVICE),
                          ),
                        ),
                        const SizedBox(height: PdSpacing.sm),
                        CustomerServiceActionCard(
                          icon: Icons.video_call_outlined,
                          title: 'অনলাইন পরামর্শ',
                          subtitle: 'শীঘ্রই চালু হবে — এখন ট্যাপ করে জানুন।',
                          muted: true,
                          onTap: () => context.push(
                            _bookingWithPreset(
                              ServiceRequestType.ONLINE_CONSULTATION_LATER,
                            ),
                          ),
                        ),
                        const SizedBox(height: PdSpacing.xl),
                        const CustomerHomeSectionTitle(title: 'দ্রুত পথ'),
                        CustomerShortcutCard(
                          icon: Icons.pets_rounded,
                          title: 'আমার পশু',
                          subtitle: 'প্রোফাইল ও তালিকা',
                          onTap: onOpenAnimalsTab,
                        ),
                        const SizedBox(height: PdSpacing.sm),
                        CustomerShortcutCard(
                          icon: Icons.assignment_outlined,
                          title: 'আমার অনুরোধ',
                          subtitle: 'সব অনুরোধ দেখুন ও ট্র্যাক করুন',
                          onTap: () =>
                              context.push(ServiceRequestsListScreen.routePath),
                        ),
                        const SizedBox(height: PdSpacing.sm),
                        CustomerShortcutCard(
                          icon: Icons.menu_book_outlined,
                          title: 'নলেজ ও টিউটোরিয়াল',
                          subtitle: 'গাইড ও প্রাণস্বাস্থ্য টিপস',
                          onTap: () =>
                              context.push(TutorialListScreen.routePath),
                        ),
                        const SizedBox(height: PdSpacing.xl),
                        const CustomerHomeSectionTitle(
                          title: 'সাম্প্রতিক অনুরোধ',
                        ),
                        CustomerRecentRequestCard(
                          onOpenRequestsTab: onOpenRequestsTab,
                          onOpenBooking: () =>
                              context.push(BookingWizardScreen.routePath),
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
