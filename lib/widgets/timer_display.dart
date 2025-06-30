import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final String Function(int) formatDuration;
  
  const TimerDisplay({
    Key? key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.formatDuration,
  }) : super(key: key);
  
  double _getProgress() {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Timer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),
          Text(
            formatDuration(remainingSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isRunning ? Colors.blue : Colors.grey.shade700,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 20),
          if (totalSeconds > 0)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                value: _getProgress(),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isRunning ? Colors.blue : Colors.grey.shade500,
                ),
                minHeight: 8,
              ),
            ),
        ],
      ),
    );
  }
}