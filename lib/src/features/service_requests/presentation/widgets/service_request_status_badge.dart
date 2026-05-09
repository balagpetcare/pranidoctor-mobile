import 'package:flutter/material.dart';

import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

class ServiceRequestStatusBadge extends StatelessWidget {
  const ServiceRequestStatusBadge({super.key, required this.status});

  final ServiceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = _colors(status, scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.labelBn,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

(Color bg, Color fg) _colors(ServiceRequestStatus s, ColorScheme scheme) {
  return switch (s) {
    ServiceRequestStatus.PENDING => (
      scheme.secondaryContainer,
      scheme.onSecondaryContainer,
    ),
    ServiceRequestStatus.ACCEPTED ||
    ServiceRequestStatus.ASSIGNED ||
    ServiceRequestStatus.IN_PROGRESS => (
      scheme.tertiaryContainer,
      scheme.onTertiaryContainer,
    ),
    ServiceRequestStatus.COMPLETED => (
      scheme.primaryContainer,
      scheme.onPrimaryContainer,
    ),
    ServiceRequestStatus.CANCELLED || ServiceRequestStatus.REJECTED => (
      scheme.errorContainer,
      scheme.onErrorContainer,
    ),
  };
}
