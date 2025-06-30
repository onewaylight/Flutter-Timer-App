import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../services/timer_service.dart';
import '../widgets/timer_display.dart';
import '../widgets/time_input_section.dart';
import '../widgets/control_buttons.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  late TimerService _timerService;
  late NotificationService _notificationService;
  
  // Controllers for time input
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _notificationService = NotificationService();
    _timerService = TimerService(
      onTimerUpdate: _onTimerUpdate,
      onTimerComplete: _onTimerComplete,
    );
    
    _initializeServices();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerService.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }
  
  // Handle app lifecycle changes for background functionality
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _timerService.isRunning) {
      _notificationService.showBackgroundNotification(_timerService.remainingSeconds);
    }
  }
  
  void _onTimerUpdate() {
    setState(() {});
    if (_timerService.isRunning) {
      _notificationService.showBackgroundNotification(_timerService.remainingSeconds);
    }
  }
  
  void _onTimerComplete() {
    setState(() {});
    HapticFeedback.heavyImpact();
    _notificationService.showCompletionNotification(_timerService.totalSeconds);
    _showCompletionDialog();
  }
  
  void _setTimer() {
    int hours = int.tryParse(_hoursController.text) ?? 0;
    int minutes = int.tryParse(_minutesController.text) ?? 0;
    int seconds = int.tryParse(_secondsController.text) ?? 0;
    
    if (hours == 0 && minutes == 0 && seconds == 0) {
      _showSnackBar('Please set a valid time duration');
      return;
    }
    
    _timerService.setTimer(hours, minutes, seconds);
    setState(() {});
    
    _showSnackBar('Timer set for ${_timerService.formatDuration(_timerService.totalSeconds)}');
  }
  
  void _startTimer() {
    if (_timerService.remainingSeconds <= 0) {
      _showSnackBar('Please set a timer first');
      return;
    }
    
    _timerService.start();
    setState(() {});
    _notificationService.showBackgroundNotification(_timerService.remainingSeconds);
  }
  
  void _pauseTimer() {
    _timerService.pause();
    setState(() {});
    _notificationService.cancelBackgroundNotification();
  }
  
  void _stopTimer() {
    _timerService.stop();
    setState(() {});
    _notificationService.cancelBackgroundNotification();
    _stopTimerAsync();
    
  }

  // add async function 
  Future<void> _stopTimerAsync() async {
    await _notificationService.flutterLocalNotificationsPlugin.cancelAll();
  }
  
  void _resetTimer() {
    _timerService.reset();
    setState(() {});
    
    _hoursController.clear();
    _minutesController.clear();
    _secondsController.clear();
    
    _notificationService.cancelBackgroundNotification();
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Timer Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.alarm,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Your ${_timerService.formatDuration(_timerService.totalSeconds)} timer has finished.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: Text('Reset Timer'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timer Display
                Expanded(
                  flex: 2,
                  child: TimerDisplay(
                    remainingSeconds: _timerService.remainingSeconds,
                    totalSeconds: _timerService.totalSeconds,
                    isRunning: _timerService.isRunning,
                    formatDuration: _timerService.formatDuration,
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Time Input Section
                TimeInputSection(
                  hoursController: _hoursController,
                  minutesController: _minutesController,
                  secondsController: _secondsController,
                  onSetTimer: _setTimer,
                ),
                
                SizedBox(height: 30),
                
                // Control Buttons
                ControlButtons(
                  isRunning: _timerService.isRunning,
                  isPaused: _timerService.isPaused,
                  remainingSeconds: _timerService.remainingSeconds,
                  onStart: _startTimer,
                  onPause: _pauseTimer,
                  onStop: _stopTimer,
                  onReset: _resetTimer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}