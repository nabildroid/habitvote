List<DateTime> preventDayDuplication(List<DateTime> days) {
  if (days.isEmpty) return [];

  final d = List<DateTime>.from(days);
  d.sort((a, b) => a.compareTo(b));

  final Map<String, DateTime> outputs = {};
  for (final e in d) {
    outputs["${e.month}-${e.day}-${e.year}"] = e;
  }

  return outputs.values.toList();
}

extension DayStartAtMid on DateTime {
  /// if two defferent days are compared, it will return the difference in days not the hours
  Duration diffDay(DateTime other) {
    if (other.weekday != this.weekday) {
      final diff = other.difference(this).inHours.abs();

      if (diff < 48) {
        // in case of 02/03 1am -> 02/04 23pm => diff is one day
        final diffInDay = (other.weekday - this.weekday).abs();
        if (diffInDay == 1 || diffInDay == 6) {
          return Duration(hours: 25);
        }
      }

      final hours = (diff / 24).floor() + 1;
      return Duration(hours: hours * 24);
    }
    return other.difference(this).abs();
  }
}
