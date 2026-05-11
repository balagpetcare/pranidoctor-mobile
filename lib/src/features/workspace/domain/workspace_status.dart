enum WorkspaceStatus {
  active,
  pending,
  suspended,
  rejected,
  inactive,
}

extension WorkspaceStatusX on WorkspaceStatus {
  String get labelBn {
    switch (this) {
      case WorkspaceStatus.active:
        return 'সক্রিয়';
      case WorkspaceStatus.pending:
        return 'পরীক্ষাধীন';
      case WorkspaceStatus.suspended:
        return 'স্থগিত';
      case WorkspaceStatus.rejected:
        return 'অসম্পূর্ণ';
      case WorkspaceStatus.inactive:
        return 'নিষ্ক্রিয়';
    }
  }

  bool get isAccessible => this == WorkspaceStatus.active;
}

