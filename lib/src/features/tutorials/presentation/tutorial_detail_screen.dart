import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/tutorials/application/tutorials_providers.dart';

class TutorialDetailScreen extends ConsumerWidget {
  const TutorialDetailScreen({super.key, required this.slugOrId});

  final String slugOrId;

  static const routeName = 'tutorialDetail';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decoded = Uri.decodeComponent(slugOrId);
    final async = ref.watch(tutorialDetailProvider(decoded));
    final hPad = pdScreenPadding(context).horizontal;
    final maxW = pdReadableMaxWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text('টিউটোরিয়াল')),
      body: async.when(
        data: (detail) {
          final scheme = Theme.of(context).colorScheme;
          final dateLabel = _formatDate(context, detail.publishedAt);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (detail.coverImageUrl != null &&
                        detail.coverImageUrl!.trim().isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            detail.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: scheme.surfaceContainerHighest,
                                  height: 180,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      detail.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaRow(
                          icon: Icons.folder_outlined,
                          text: detail.category.nameBn.isNotEmpty
                              ? detail.category.nameBn
                              : (detail.category.nameEn ??
                                    detail.category.slug),
                        ),
                        if (dateLabel != null)
                          _MetaRow(icon: Icons.event_outlined, text: dateLabel),
                        if (detail.author.displayName != null &&
                            detail.author.displayName!.trim().isNotEmpty)
                          _MetaRow(
                            icon: Icons.person_outline,
                            text: detail.author.displayName!,
                          ),
                      ],
                    ),
                    if (detail.summary != null &&
                        detail.summary!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        detail.summary!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SelectableText(
                      detail.body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.55),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: () {
                    ref.invalidate(tutorialDetailProvider(decoded));
                  },
                  child: const Text('আবার চেষ্টা করুন'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('তালিকায় ফিরুন'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String? _formatDate(BuildContext context, DateTime? d) {
  if (d == null) return null;
  final loc = Localizations.localeOf(context);
  try {
    return DateFormat.yMMMd(loc.toLanguageTag()).format(d.toLocal());
  } catch (_) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
