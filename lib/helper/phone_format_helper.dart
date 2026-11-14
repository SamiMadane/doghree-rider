class PhoneFormat {
  PhoneFormat._();

  /// Trims the number and adds a leading `+` only when it is missing.
  /// Routes now carry the number URL-encoded (audit row 51), so the `+` is
  /// no longer turned into a space and must not be added twice.
  static String withPlus(String? number) {
    final String n = (number ?? '').trim();
    if (n.isEmpty || n.startsWith('+')) return n;
    return '+$n';
  }
}
