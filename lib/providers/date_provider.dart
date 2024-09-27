import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateProvider extends AutoDisposeNotifier<DateTime> {
  DateTime? _nextMidnight;
  Timer? _timer;

  @override
  DateTime build() {
    _nextMidnight = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    _startMidnightCheckTimer();
    return DateTime.now();
  }

  void _startMidnightCheckTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkMidnight();
    });
  }

  void _checkMidnight() {
    final now = DateTime.now();
    if (now.isAfter(_nextMidnight!)) {
      state = DateTime.now();

      _nextMidnight = _nextMidnight!.add(const Duration(days: 1));
    }
  }
}

final dateProvider = AutoDisposeNotifierProvider<DateProvider, DateTime>(
  () => DateProvider(),
);
