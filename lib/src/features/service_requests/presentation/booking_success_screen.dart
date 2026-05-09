import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_buttons.dart';
import 'package:pranidoctor_mobile/src/features/home/home_shell_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_request_detail_screen.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/service_requests_list_screen.dart';

/// Shown after [POST /api/mobile/service-requests] succeeds.
///
/// Pass [ServiceRequest] via `GoRouterState.extra`.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.request});

  final ServiceRequest request;

  static const routePath = '/booking/success';
  static const routeName = 'bookingSuccess';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = pdScreenPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('অনুরোধ জমা হয়েছে')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: pad.copyWith(top: PdSpacing.lg, bottom: PdSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle_rounded, size: 72, color: scheme.primary),
              const SizedBox(height: PdSpacing.md),
              Text(
                'ধন্যবাদ!',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: PdSpacing.sm),
              Text(
                'আপনার সেবা অনুরোধ গ্রহণ করা হয়েছে। শীঘ্রই যোগাযোগ করা হবে।',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PdSpacing.xl),
              _SummaryTile(
                label: 'সেবার ধরন',
                value: request.serviceType.labelBn,
              ),
              _SummaryTile(label: 'স্ট্যাটাস', value: request.status.labelBn),
              if (request.animal != null)
                _SummaryTile(
                  label: 'পশু',
                  value: '${request.animal!.name} (${request.animal!.species})',
                ),
              if (request.problemOrSymptom?.trim().isNotEmpty == true)
                _SummaryTile(
                  label: 'সমস্যা / লক্ষণ',
                  value: request.problemOrSymptom!,
                ),
              const SizedBox(height: PdSpacing.xl),
              PdPrimaryButton(
                label: 'অনুরোধের বিস্তারিত দেখুন',
                onPressed: () => context.push(
                  ServiceRequestDetailScreen.routePathFor(request.id),
                ),
              ),
              const SizedBox(height: PdSpacing.sm),
              PdSecondaryButton(
                label: 'আমার সব অনুরোধ',
                onPressed: () =>
                    context.push(ServiceRequestsListScreen.routePath),
              ),
              const SizedBox(height: PdSpacing.sm),
              PdSecondaryButton(
                label: 'হোমে ফিরুন',
                onPressed: () => context.go(HomeShellScreen.routePath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PdSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
