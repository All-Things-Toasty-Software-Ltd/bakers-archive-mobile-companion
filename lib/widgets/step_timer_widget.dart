import 'package:flutter/material.dart';
import '../core/theme/bread_colors.dart';

/// Floating or embedded countdown timer for baking and cooking steps.
class StepTimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final bool isRunning;
  final VoidCallback onPauseResume;
  final VoidCallback onReset;

  const StepTimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.isRunning,
    required this.onPauseResume,
    required this.onReset,
  });

  String _formatTime(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = secondsRemaining == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isComplete
            ? BreadColors.yeastGreen.withValues(alpha: 0.15)
            : BreadColors.crustGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isComplete ? BreadColors.yeastGreen : BreadColors.crustGold,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.timer_outlined,
            color: isComplete ? BreadColors.yeastGreen : BreadColors.crustGoldDark,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isComplete ? "Done!" : _formatTime(secondsRemaining),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              color: isComplete ? BreadColors.yeastGreen : BreadColors.crustGoldDark,
            ),
          ),
          const SizedBox(width: 12),

          if (!isComplete) ...[
            InkWell(
              onTap: onPauseResume,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: BreadColors.crustGoldDark,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],

          InkWell(
            onTap: onReset,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.refresh,
                color: BreadColors.crustGoldDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
