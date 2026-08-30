class DisplayNames {
  const DisplayNames._();

  static bool looksArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  static ({String primary, String? secondary}) resolve({
    required String fallback,
    String? first,
    String? second,
  }) {
    final String left = first?.trim() ?? '';
    final String right = second?.trim() ?? '';

    if (left.isEmpty && right.isEmpty) {
      return (primary: fallback, secondary: null);
    }

    if (left.isEmpty) {
      return (primary: right, secondary: null);
    }

    if (right.isEmpty || right == left) {
      return (primary: left, secondary: null);
    }

    if (looksArabic(right) && !looksArabic(left)) {
      return (primary: right, secondary: left);
    }

    return (primary: left, secondary: right);
  }
}
