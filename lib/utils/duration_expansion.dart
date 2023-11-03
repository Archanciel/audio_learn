// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

/// Add format methods to the Duration class.
extension DurationExpansion on Duration {
  static final NumberFormat numberFormatTwoInt = NumberFormat('00');

  /// returns the Duration formatted as HH:mm
  String HHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// returns the Duration formatted as HH:mm:ss
  String HHmmss() {
    int durationMinute = inMinutes.remainder(60);
    int durationSecond = inSeconds.remainder(60);
    String minusStr = '';

    if (inMinutes < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}:${numberFormatTwoInt.format(durationSecond.abs())}";
  }

  /// returns the Duration formatted as dd:HH:mm
  String ddHHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';
    int durationHour =
        Duration(minutes: (inMinutes - durationMinute)).inHours.remainder(24);
    int durationDay = Duration(hours: (inHours - durationHour)).inDays;

    if (inMinutes < 0) {
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
    String hours = (inHours > 0) ? '$inHours:' : '';
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));

    return '$hours$twoDigitMinutes:$twoDigitSeconds';
  }
}
