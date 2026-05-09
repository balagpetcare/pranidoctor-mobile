import 'package:flutter/material.dart';

/// Shows network photo when [photoUrl] is valid; otherwise a themed placeholder.
/// Image upload is not implemented server-side — placeholder only (see docs).
class AnimalPhotoPlaceholder extends StatelessWidget {
  const AnimalPhotoPlaceholder({
    super.key,
    required this.photoUrl,
    this.size = 72,
  });

  final String? photoUrl;
  final double size;

  bool get _hasUrl =>
      photoUrl != null &&
      photoUrl!.trim().isNotEmpty &&
      (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dim = size.clamp(40.0, 120.0);

    if (_hasUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          photoUrl!.trim(),
          width: dim,
          height: dim,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallback(context, scheme, dim),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: dim,
              height: dim,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return _fallback(context, scheme, dim);
  }

  Widget _fallback(BuildContext context, ColorScheme scheme, double dim) {
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.pets_rounded, size: dim * 0.45, color: scheme.primary),
    );
  }
}
