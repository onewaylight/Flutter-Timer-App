import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  
  final VoidCallback? onTimerUpdate;
  final VoidCallback? onTimerComplete;
  
  TimerService({
    this.onTimerUpdate,
    this.onTimerComplete,
  });
  
  // Getters
  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  
  void setTimer(int hours, int minutes, int seconds) {
    _totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
    _remainingSeconds = _totalSeconds;
    _isRunning = false;
    _isPaused = false;
  }
  
  void start() {
    if (_remainingSeconds <= 0) return;
    
    _isRunning = true;
    _isPaused = false;
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTimerUpdate?.call();
      } else {
        _timer?.cancel();
        _isRunning = false;
        onTimerComplete?.call();
      }
    });
  }
  
  void pause() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
  }
  
  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = _totalSeconds;
  }
  
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = 0;
    _totalSeconds = 0;
  }
  
  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  double getProgress() {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }
  
  void dispose() {
    _timer?.cancel();
  }
}