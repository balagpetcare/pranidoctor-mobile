import 'dart:io';

import 'package:crypto/crypto.dart';

Future<String> sha256HexForFile(String path) async {
  final digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
}
