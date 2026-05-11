// File size and extension checks for picked images (VM / mobile).
import 'dart:io';

int profileImageFileLengthBytes(String path) => File(path).lengthSync();

bool profileImagePathLooksSupported(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.heic') ||
      lower.endsWith('.heif');
}
