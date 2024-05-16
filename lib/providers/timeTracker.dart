import 'package:flutter/material.dart';

class TimeTracker extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;

  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  void startTracking() {
    _startTime = DateTime.now();
    notifyListeners();
  }

  void stopTracking() {
    _endTime = DateTime.now();
    notifyListeners();
  }

  void resetTracking() {
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }
}
