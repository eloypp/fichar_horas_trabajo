import 'dart:async';
import 'package:flutter/material.dart';

class TimeTracker extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;

  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  Duration get currentDuration => _currentDuration;

  void startTracking() {
    _startTime = DateTime.now();
    _endTime = null;
    _currentDuration = Duration.zero;

    _timer?.cancel();  // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _currentDuration = DateTime.now().difference(_startTime!);
      notifyListeners();
    });

    notifyListeners();
  }

  void stopTracking() {
    _timer?.cancel();
    _endTime = DateTime.now();
    _currentDuration = _endTime!.difference(_startTime!);
    notifyListeners();
  }

  void resetTracking() {
    _timer?.cancel();
    _startTime = null;
    _endTime = null;
    _currentDuration = Duration.zero;
    notifyListeners();
  }

  String get formattedDuration {
    final hours = _currentDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_currentDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_currentDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
