/// Bengali script block (Bangla letters, digits, some punctuation used in BN).
bool textContainsBengaliScript(String input) {
  return RegExp(r'[\u0980-\u09FF]').hasMatch(input);
}

/// Village / locality name typed by user must include at least one Bengali character.
String? validateOptionalBnVillageName(String? raw) {
  final t = raw?.trim() ?? '';
  if (t.isEmpty) return null;
  if (t.length < 2) {
    return 'গ্রামের নাম কমপক্ষে ২ অক্ষরের হতে হবে।';
  }
  if (!textContainsBengaliScript(t)) {
    return 'গ্রামের নাম বাংলায় লিখুন (বাংলা অক্ষর থাকতে হবে)।';
  }
  return null;
}
