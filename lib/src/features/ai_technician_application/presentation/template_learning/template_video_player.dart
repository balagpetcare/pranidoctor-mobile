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
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_cache.dart';

/// Opens a modal bottom sheet with an authenticated upload video.
Future<void> showTemplateVideoPlayerSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String uploadId,
  required VoidCallback onEngaged,
}) {
  onEngaged();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _TemplateVideoPlayerSheet(uploadId: uploadId),
  );
}

class _TemplateVideoPlayerSheet extends ConsumerStatefulWidget {
  const _TemplateVideoPlayerSheet({required this.uploadId});

  final String uploadId;

  @override
  ConsumerState<_TemplateVideoPlayerSheet> createState() =>
      _TemplateVideoPlayerSheetState();
}

class _TemplateVideoPlayerSheetState
    extends ConsumerState<_TemplateVideoPlayerSheet> {
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
      TemplateMediaCache.instance.put('__vid_${widget.uploadId}', bytes);
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

/// Inline play row for external video URLs.
class TemplateExternalVideoLauncher extends StatelessWidget {
  const TemplateExternalVideoLauncher({
    super.key,
    required this.label,
    required this.url,
  });

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.play_circle_outline_rounded, color: scheme.primary),
      title: Text(label),
      subtitle: Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: PraniTextStyles.caption(scheme, textTheme),
      ),
      onTap: () async {
        final uri = Uri.tryParse(url.trim());
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
