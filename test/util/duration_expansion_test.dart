import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/utils/duration_expansion.dart';

void main() {
  group('DurationExpansion HHmmss test not performed in DateTimeParser test',
      () {
    test(
      'Duration 13 hours 35 minutes 23 seconds',
      () {
        const Duration duration = Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmss(), '13:35:23');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5, seconds: 2);

        expect(duration.HHmmss(), '3:05:02');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5);

        expect(duration.HHmmss(), '3:05:00');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(hours: 3, minutes: 5, seconds: 2));

        expect(duration.HHmmss(), '-3:05:02');
      },
    );

    test(
      'Duration 0 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 5);

        expect(duration.HHmmss(), '0:05:00');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2));

        expect(duration.HHmmss(), '-0:05:02');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds',
      () {
        final Duration duration =
            const Duration(milliseconds: 0) - (const Duration(seconds: 2));

        expect(duration.HHmmss(), '-0:00:02');
      },
    );
  });

  group(
      'DurationExpansion HHmmssZeroHH test not performed in DateTimeParser test',
      () {
    test(
      'Duration 13 hours 35 minutes 23 seconds',
      () {
        const Duration duration = Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmssZeroHH(), '13:35:23');
      },
    );

    test(
      'Duration -13 hours 35 minutes 23 seconds',
      () {
        final Duration duration = const Duration(microseconds: 0) -
            Duration(hours: 13, minutes: 35, seconds: 23);

        expect(duration.HHmmssZeroHH(), '-13:35:23');
      },
    );

    test(
      'Duration 3 hours 5 minutes 2 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5, seconds: 2);

        expect(duration.HHmmssZeroHH(), '3:05:02');
      },
    );

    test(
      'Duration 3 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(hours: 3, minutes: 5);

        expect(duration.HHmmssZeroHH(), '3:05:00');
      },
    );

    test(
      'Duration -3 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(hours: 3, minutes: 5, seconds: 2));

        expect(duration.HHmmssZeroHH(), '-3:05:02');
      },
    );

    test(
      'Duration 0 hours 15 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 15);

        expect(duration.HHmmssZeroHH(), '15:00');
      },
    );

    test(
      'Duration 0 hours 5 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 5);

        expect(duration.HHmmssZeroHH(), '5:00');
      },
    );

    test(
      'Duration 0 hours 15 minutes 0 seconds',
      () {
        const Duration duration = Duration(minutes: 15);

        expect(duration.HHmmssZeroHH(), '15:00');
      },
    );

    test(
      'Duration -0 hours 5 minutes 2 seconds',
      () {
        final Duration duration = const Duration(milliseconds: 0) -
            (const Duration(minutes: 5, seconds: 2));

        expect(duration.HHmmssZeroHH(), '-5:02');
      },
    );

    test(
      'Duration 0 hours 0 minutes 2 seconds',
      () {
        const Duration duration = Duration(seconds: 2);

        expect(duration.HHmmssZeroHH(), '0:02');
      },
    );

    test(
      'Duration 0 hours 0 minutes 0 seconds',
      () {
        const Duration duration = Duration(seconds: 0);

        expect(duration.HHmmssZeroHH(), '0:00');
      },
    );

    test(
      'Duration -0 hours 0 minutes 2 seconds',
      () {
        final Duration duration =
            const Duration(milliseconds: 0) - (const Duration(seconds: 2));

        expect(duration.HHmmssZeroHH(), '-0:02');
      },
    );
  });
}
