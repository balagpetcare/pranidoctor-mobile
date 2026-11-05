class ServiceInstanceListItem {
  const ServiceInstanceListItem({
    required this.id,
    required this.status,
    required this.version,
    required this.updatedAt,
    this.submittedAt,
    required this.templateId,
    required this.templateName,
  });

  final String id;
  final String status;
  final int version;
  final String updatedAt;
  final String? submittedAt;
  final String templateId;
  final String templateName;

  factory ServiceInstanceListItem.fromJson(Map<String, dynamic> j) {
    final t = j['template'] as Map<String, dynamic>? ?? {};
    return ServiceInstanceListItem(
      id: j['id'] as String,
      status: j['status'] as String,
      version: (j['version'] as num?)?.toInt() ?? 0,
      updatedAt: j['updatedAt'] as String,
      submittedAt: j['submittedAt'] as String?,
      templateId: t['id'] as String? ?? '',
      templateName: t['internalName'] as String? ?? '',
    );
  }
}
