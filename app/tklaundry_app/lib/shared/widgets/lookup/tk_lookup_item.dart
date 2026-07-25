class TkLookupItem<T> {
  const TkLookupItem({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    if (label.toLowerCase().contains(q)) return true;
    if (subtitle != null && subtitle!.toLowerCase().contains(q)) return true;
    if (value.toString().toLowerCase().contains(q)) return true;
    return false;
  }
}
