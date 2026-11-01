const Map<String, String> _methodLogos = <String, String>{};

String? walletMethodLogo(String name) {
  for (final MapEntry<String, String> e in _methodLogos.entries) {
    if (name.contains(e.key)) return e.value;
  }
  return null;
}
