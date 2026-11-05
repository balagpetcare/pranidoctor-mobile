import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/template_learning/template_media_cache.dart';

/// Authenticated `/api/mobile/uploads/:id` image with LRU memory cache.
class TemplateAuthenticatedImage extends ConsumerStatefulWidget {
  const TemplateAuthenticatedImage({
    super.key,
    required this.uploadId,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
    this.heroTag,
  });

  final String uploadId;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  ConsumerState<TemplateAuthenticatedImage> createState() =>
      _TemplateAuthenticatedImageState();
}

class _TemplateAuthenticatedImageState
    extends ConsumerState<TemplateAuthenticatedImage> {
  Uint8List? _bytes;
  Object? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(covariant TemplateAuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uploadId != widget.uploadId) {
      _bytes = null;
      _err = null;
      _loading = true;
      Future<void>.microtask(_load);
    }
  }

  Future<void> _load() async {
    final id = widget.uploadId.trim();
    if (id.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final cached = TemplateMediaCache.instance.get(id);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _bytes = cached;
          _err = null;
          _loading = false;
        });
      }
      return;
    }
    try {
      final dio = ref.read(apiClientProvider).dio;
      final res = await dio.get<List<int>>(
        'api/mobile/uploads/$id',
        options: Options(
          responseType: ResponseType.bytes,
          headers: <String, dynamic>{Headers.acceptHeader: '*/*'},
        ),
      );
      if (!mounted) return;
      if ((res.statusCode ?? 0) >= 200 &&
          (res.statusCode ?? 0) < 300 &&
          res.data != null) {
        final u = Uint8List.fromList(res.data!);
        TemplateMediaCache.instance.put(id, u);
        setState(() {
          _bytes = u;
          _err = null;
          _loading = false;
        });
      } else {
        setState(() {
          _err = 'http';
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
    final scheme = Theme.of(context).colorScheme;
    Widget inner;
    if (_loading) {
      inner = ColoredBox(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (_err != null || _bytes == null || _bytes!.isEmpty) {
      inner = ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );
    } else {
      inner = Image.memory(_bytes!, fit: widget.fit, gaplessPlayback: true);
    }

    if (widget.heroTag != null) {
      inner = Hero(tag: widget.heroTag!, child: inner);
    }

    inner = ClipRRect(
      borderRadius:
          widget.borderRadius ?? BorderRadius.circular(PraniRadius.md),
      child: inner,
    );

    if (widget.onTap != null) {
      inner = Material(
        color: Colors.transparent,
        child: InkWell(onTap: widget.onTap, child: inner),
      );
    }

    return inner;
  }
}
