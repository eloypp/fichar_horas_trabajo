import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimeRecord {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String department;
  final String concept;

  TimeRecord({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.department,
    required this.concept,
  });
}

class TimeTracker extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  final List<TimeRecord> _records = [];
  String? _selectedDepartment;
  String? _concept;

  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  Duration get currentDuration => _currentDuration;
  List<TimeRecord> get records => List.unmodifiable(_records);

  void setSelectedDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void setConcept(String concept) {
    _concept = concept;
    notifyListeners();
  }

  void startTracking() {
    if (_selectedDepartment == null || _concept == null || _concept!.isEmpty) {
      // Handle error: Show dialog to user
      return;
    }

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

    final record = TimeRecord(
      date: _startTime!,
      startTime: _startTime!,
      endTime: _endTime!,
      duration: _currentDuration,
      department: _selectedDepartment!,
      concept: _concept!,
    );

    _records.insert(0, record);

    // Save to Firestore
    FirebaseFirestore.instance.collection('trackingHistory').add({
      'date': record.date,
      'startTime': record.startTime,
      'endTime': record.endTime,
      'duration': record.duration.inSeconds,
      'department': record.department,
      'concept': record.concept,
      'user': FirebaseAuth.instance.currentUser!.displayName,
    });

    notifyListeners();
  }

  void resetTracking() {
    _timer?.cancel();
    _startTime = null;
    _endTime = null;
    _currentDuration = Duration.zero;
    _selectedDepartment = null;
    _concept = null;
    notifyListeners();
  }

  String get formattedDuration {
    final hours = _currentDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_currentDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_currentDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year}';
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
