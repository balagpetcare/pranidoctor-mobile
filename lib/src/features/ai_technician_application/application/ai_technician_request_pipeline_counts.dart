/// Client-side aggregation using existing [AiTechnicianRepository.listTechnicianJobRequests].
///
/// TODO(backend): Expose per-tab totals on `GET .../dashboard` or a lightweight
/// `GET .../requests/counts` to avoid N paginated list calls and truncation.
class AiTechnicianRequestPipelineCount {
  const AiTechnicianRequestPipelineCount({
    required this.count,
    this.truncated = false,
    this.available = true,
  });

  /// Request rows returned for this tab (paginated).
  final int count;

  /// True when the API indicates more rows exist beyond [count].
  final bool truncated;

  /// False when the list call failed (network/auth); UI should fall back to [—].
  final bool available;

  factory AiTechnicianRequestPipelineCount.unavailable() =>
      const AiTechnicianRequestPipelineCount(count: 0, available: false);

  /// Display for dashboard rows; null means show fallback em-dash.
  String? get displayText {
    if (!available) return null;
    if (truncated) return '$count+';
    return '$count';
  }
}
