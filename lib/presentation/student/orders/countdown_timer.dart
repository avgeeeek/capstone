import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime estimatedReadyAt;

  const CountdownTimerWidget({super.key, required this.estimatedReadyAt});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.estimatedReadyAt.difference(DateTime.now());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.estimatedReadyAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remaining.isNegative || _remaining.inSeconds <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Icon(
                  Icons.timer_outlined,
                  color: Colors.white.withOpacity(0.7 + 0.3 * _pulseController.value),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Estimated Ready In',
                style: TextStyle(
                  color: Colors.white70, fontSize: 14,
                  fontFamily: 'Inter', fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isExpired
              ? Column(
                  children: const [
                    Icon(Icons.celebration_rounded, color: Colors.white, size: 40),
                    SizedBox(height: 6),
                    Text(
                      'Should be ready soon!',
                      style: TextStyle(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, fontFamily: 'Inter',
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      DateFormatter.formatCountdownReadable(_remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_remaining.inMinutes > 0 ? '${_remaining.inMinutes} min' : ''} ${_remaining.inSeconds.remainder(60)} sec remaining',
                      style: const TextStyle(
                        color: Colors.white60, fontSize: 13, fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          // Progress bar
          if (!isExpired) _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final totalSeconds = widget.estimatedReadyAt
        .difference(widget.estimatedReadyAt.subtract(
            Duration(seconds: widget.estimatedReadyAt
                .difference(DateTime.now().subtract(_remaining))
                .inSeconds + _remaining.inSeconds)))
        .inSeconds;
    final elapsed = totalSeconds - _remaining.inSeconds;
    final progress = totalSeconds > 0 ? (elapsed / totalSeconds).clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 6,
      ),
    );
  }
}
