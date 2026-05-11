/// TTL hint for repository reads (sqflite / Drift wrappers can enforce this).
class RepositoryCachePolicy {
  const RepositoryCachePolicy({
    this.softTtl = const Duration(minutes: 5),
    this.hardTtl = const Duration(hours: 24),
  });

  final Duration softTtl;
  final Duration hardTtl;
}
