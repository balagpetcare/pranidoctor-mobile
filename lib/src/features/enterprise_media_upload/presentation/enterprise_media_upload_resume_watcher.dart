import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/enterprise_media_upload_providers.dart';

/// Main-isolate resume hook; pair with OS background tasks later via same manager.
class EnterpriseMediaUploadResumeWatcher extends ConsumerStatefulWidget {
  const EnterpriseMediaUploadResumeWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<EnterpriseMediaUploadResumeWatcher> createState() =>
      _EnterpriseMediaUploadResumeWatcherState();
}

class _EnterpriseMediaUploadResumeWatcherState
    extends ConsumerState<EnterpriseMediaUploadResumeWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(enterpriseMediaUploadManagerProvider).processQueue(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
