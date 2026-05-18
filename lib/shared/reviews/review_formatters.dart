String formatReviewAverage(double average) {
  final formatted = average.toStringAsFixed(1).replaceAll('.', ',');
  return formatted.endsWith(',0')
      ? formatted.substring(0, formatted.length - 2)
      : formatted;
}
