import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';

/// Cover, gallery thumbnails (authenticated), and video links / previews.
class TemplateMediaStrip extends ConsumerWidget {
  const TemplateMediaStrip({super.key, required this.media});

  final List<SemenCatalogMediaLine> media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.isEmpty) return const SizedBox.shrink();

    SemenCatalogMediaLine? cover;
    for (final m in media) {
      if (m.kind == 'COVER' && (m.uploadedFileId?.trim().isNotEmpty ?? false)) {
        cover = m;
        break;
      }
    }
    final gallery = media
        .where(
          (m) =>
              m.kind == 'GALLERY' &&
              (m.uploadedFileId?.trim().isNotEmpty ?? false),
        )
        .toList();
    final videos = media
        .where((m) => m.kind == 'VIDEO_URL' || m.kind == 'VIDEO_UPLOAD')
        .toList();

    if (cover == null && gallery.isEmpty && videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cover != null)
          Padding(
            padding: const EdgeInsets.only(bottom: PraniSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PraniRadius.lg),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _TemplateAuthImage(uploadId: cover.uploadedFileId!),
              ),
            ),
          ),
        if (gallery.isNotEmpty)
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: PraniSpacing.sm),
              itemBuilder: (context, i) {
                final id = gallery[i].uploadedFileId!;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(PraniRadius.md),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: _TemplateAuthImage(uploadId: id),
                  ),
                );
              },
            ),
          ),
        if (videos.isNotEmpty) ...[
          const SizedBox(height: PraniSpacing.md),
          ...videos.map((v) => _VideoRow(line: v)),
        ],
      ],
    );
  }
}

class _VideoRow extends ConsumerWidget {
  const _VideoRow({required this.line});

  final SemenCatalogMediaLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (line.kind == 'VIDEO_URL' &&
        (line.externalUrl?.trim().isNotEmpty ?? false)) {
      final uri = Uri.tryParse(line.externalUrl!.trim());
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.play_circle_outline_rounded, color: scheme.primary),
        title: const Text('ভিডিও লিঙ্ক'),
        subtitle: Text(
          line.externalUrl!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PraniTextStyles.caption(scheme, textTheme),
        ),
        onTap: () async {
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
    }
    final id = line.uploadedFileId?.trim();
    if (line.kind == 'VIDEO_UPLOAD' && id != null && id.isNotEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.video_file_rounded, color: scheme.primary),
        title: const Text('আপলোড করা ভিডিও'),
        subtitle: const Text('দেখতে ট্যাপ করুন'),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (ctx) => _TemplateVideoSheet(uploadId: id),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _TemplateAuthImage extends ConsumerStatefulWidget {
  const _TemplateAuthImage({required this.uploadId});

  final String uploadId;

  @override
  ConsumerState<_TemplateAuthImage> createState() => _TemplateAuthImageState();
}

class _TemplateAuthImageState extends ConsumerState<_TemplateAuthImage> {
  Uint8List? _bytes;
  Object? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final res = await dio.get<List<int>>(
        'api/mobile/uploads/${widget.uploadId}',
        options: Options(
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{Headers.acceptHeader: '*/*'},
        ),
      );
      if (!mounted) return;
      if ((res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300) {
        final data = res.data;
        setState(() {
          _bytes = data != null ? Uint8List.fromList(data) : null;
          _err = null;
          _loading = false;
        });
      } else {
        setState(() {
          _err = 'load';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_err != null || _bytes == null || _bytes!.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
    return Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true);
  }
}

class _TemplateVideoSheet extends ConsumerStatefulWidget {
  const _TemplateVideoSheet({required this.uploadId});

  final String uploadId;

  @override
  ConsumerState<_TemplateVideoSheet> createState() =>
      _TemplateVideoSheetState();
}

class _TemplateVideoSheetState extends ConsumerState<_TemplateVideoSheet> {
  VideoPlayerController? _controller;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_init);
  }

  Future<void> _init() async {
    try {
      final dio = ref.read(apiClientProvider).dio;
      final res = await dio.get<List<int>>(
        'api/mobile/uploads/${widget.uploadId}',
        options: Options(
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{Headers.acceptHeader: '*/*'},
        ),
      );
      if (!mounted) return;
      if ((res.statusCode ?? 0) < 200 ||
          (res.statusCode ?? 0) >= 300 ||
          res.data == null) {
        setState(() {
          _error = StateError('video_http');
          _loading = false;
        });
        return;
      }
      final bytes = Uint8List.fromList(res.data!);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/semen_tpl_${widget.uploadId}.mp4');
      await f.writeAsBytes(bytes, flush: true);
      final ctl = VideoPlayerController.file(f);
      await ctl.initialize();
      if (!mounted) return;
      setState(() {
        _controller = ctl;
        _loading = false;
      });
      await ctl.setLooping(true);
      await ctl.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.42;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.xl),
        child: SizedBox(
          height: h,
          width: double.infinity,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    'ভিডিও লোড করা যায়নি',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio == 0
                      ? 16 / 9
                      : _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
