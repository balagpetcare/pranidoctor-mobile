import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';

class ServiceRequestAttachmentsSection extends StatelessWidget {
  const ServiceRequestAttachmentsSection({super.key, required this.attachments});

  final List<ServiceRequestAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'সংযুক্তি',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...attachments.map(
          (a) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.attach_file_outlined),
            title: Text(
              (a.label ?? a.url ?? 'ফাইল').toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: a.mimeType != null ? Text(a.mimeType!) : null,
            trailing: a.url != null && a.url!.trim().isNotEmpty
                ? IconButton(
                    tooltip: 'খুলুন',
                    icon: const Icon(Icons.open_in_new_outlined),
                    onPressed: () async {
                      final uri = Uri.tryParse(a.url!.trim());
                      if (uri == null) return;
                      final ok = await canLaunchUrl(uri);
                      if (!context.mounted) return;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('লিংক খোলা যায়নি')),
                        );
                        return;
                      }
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
