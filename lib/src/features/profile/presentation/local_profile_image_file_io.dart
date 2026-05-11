import 'dart:io';

import 'package:flutter/material.dart';

/// Local cropped image preview (mobile/desktop IO).
Widget pdLocalImageFile(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image_outlined),
  );
}
