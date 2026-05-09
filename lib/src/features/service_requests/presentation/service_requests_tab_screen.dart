import 'package:flutter/material.dart';

import 'service_requests_list_screen.dart';

/// Customer shell tab — same content as [ServiceRequestsListScreen] with shell chrome.
class ServiceRequestsTabScreen extends StatelessWidget {
  const ServiceRequestsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServiceRequestsListScreen(embeddedInShell: true);
  }
}
