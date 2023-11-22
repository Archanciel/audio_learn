// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

/// Add format methods to the Duration class.
extension DurationExpansion on Duration {
  static final NumberFormat numberFormatTwoInt = NumberFormat('00');

  /// Returns the Duration formatted as HH:mm.
  String HHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  String HHmmss() {
    int durationMinute = inMinutes.remainder(60);
    int durationSecond = inSeconds.remainder(60);
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}:${numberFormatTwoInt.format(durationSecond.abs())}";
  }

  /// Returns the Duration formatted as dd:HH:mm
  String ddHHmm() {
    int durationMinute = inMinutes.remainder(60);
    int durationHour =
        Duration(minutes: (inMinutes - durationMinute)).inHours.remainder(24);
    int durationDay = Duration(hours: (inHours - durationHour)).inDays;
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${numberFormatTwoInt.format(durationDay.abs())}:${numberFormatTwoInt.format(durationHour.abs())}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// Return Duration formatted as HH:mm:ss if the hours are > 0,
  /// else as mm:ss.
  ///
  /// Example: 1:45:24 or 45:24 if 0:45:24.
  String HHmmssZeroHH() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = '';

    if (inHours > 0) {
      hours = '$inHours:';
    } else if (inHours == 0) {
      hours = '';
    } else {
      hours = '${inHours.abs()}:';
    }

    String twoDigitMinutes;

    if (hours.isEmpty) {
      twoDigitMinutes = inMinutes.remainder(60).abs().toString();
    } else {
      twoDigitMinutes = twoDigits(inMinutes.remainder(60).abs());
    }

    String twoDigitSeconds = twoDigits((inMilliseconds.remainder(60000).abs() / 1000).round());
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return '$minusStr$hours$twoDigitMinutes:$twoDigitSeconds';
  }
}
