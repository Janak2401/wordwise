import 'dart:async';
import 'package:flutter/material.dart';

/// Counts down to local midnight, when the next daily word unlocks.
class NextWordCountdown extends StatefulWidget {
  final Color labelColor;
  final Color valueColor;
  final VoidCallback? onElapsed;

  const NextWordCountdown({
    super.key,
    required this.labelColor,
    required this.valueColor,
    this.onElapsed,
  });

  @override
  State<NextWordCountdown> createState() => _NextWordCountdownState();
}

class _NextWordCountdownState extends State<NextWordCountdown> {
  late Timer _timer;
  late Duration _remaining;
  bool _elapsedFired = false;

  @override
  void initState() {
    super.initState();
    _remaining = _untilMidnight();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  static Duration _untilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  void _tick() {
    final remaining = _untilMidnight();
    // Crossing midnight makes the next midnight a full day away again.
    final crossedMidnight = remaining > _remaining;
    setState(() => _remaining = remaining);
    if (crossedMidnight && !_elapsedFired) {
      _elapsedFired = true;
      widget.onElapsed?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'NEXT WORD IN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: widget.labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _format(_remaining),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: widget.valueColor,
          ),
        ),
      ],
    );
  }
}
