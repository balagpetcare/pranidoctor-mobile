// Web stub: file size unavailable; extension allow-list only.

int profileImageFileLengthBytes(String path) => -1;
bool profileImagePathLooksSupported(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp');
}
