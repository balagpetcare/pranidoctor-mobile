/// Upload pipeline state machine (persisted per task).
enum MediaUploadLifecycle {
  queued,
  compressing,
  preparing,
  uploading,
  verifying,
  completed,
  failed,
  retryScheduled,
}

extension MediaUploadLifecycleWire on MediaUploadLifecycle {
  String get wireName => name;

  static MediaUploadLifecycle parse(String? raw) {
    if (raw == null || raw.isEmpty) return MediaUploadLifecycle.queued;
    for (final v in MediaUploadLifecycle.values) {
      if (v.name == raw) return v;
    }
    return MediaUploadLifecycle.queued;
  }
}
