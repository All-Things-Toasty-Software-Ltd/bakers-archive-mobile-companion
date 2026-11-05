import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/bread_colors.dart';
import '../data/models/recipe_detail.dart';
import '../widgets/step_timer_widget.dart';

/// Distraction-free, large-text step-by-step assistant for baking with floury hands.
class KitchenModeScreen extends StatefulWidget {
  final RecipeDetail recipe;

  const KitchenModeScreen({super.key, required this.recipe});

  @override
  State<KitchenModeScreen> createState() => _KitchenModeScreenState();
}

class _KitchenModeScreenState extends State<KitchenModeScreen> {
  int _currentStepIndex = 0;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _initTimerForStep(_currentStepIndex);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _initTimerForStep(int index) {
    _ticker?.cancel();
    _ticker = null;
    _isTimerRunning = false;

    if (index >= 0 && index < widget.recipe.instructions.length) {
      final step = widget.recipe.instructions[index];
      _secondsRemaining = (step.timeMinutes * 60).round();
    } else {
      _secondsRemaining = 0;
    }
  }

  void _toggleTimer() {
    if (_secondsRemaining <= 0) {
      _initTimerForStep(_currentStepIndex);
      setState(() {});
      return;
    }

    if (_isTimerRunning) {
      _ticker?.cancel();
      _ticker = null;
      setState(() => _isTimerRunning = false);
      return;
    }

    setState(() => _isTimerRunning = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _ticker = null;
        setState(() => _isTimerRunning = false);
      }
    });
  }

  void _nextStep() {
    if (_currentStepIndex < widget.recipe.instructions.length - 1) {
      setState(() {
        _currentStepIndex++;
        _initTimerForStep(_currentStepIndex);
      });
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _initTimerForStep(_currentStepIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final steps = widget.recipe.instructions;

    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kitchen Mode')),
        body: const Center(child: Text('No instructions available.')),
      );
    }

    final currentStep = steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / steps.length;

    return Scaffold(
      backgroundColor: isDark ? BreadColors.ovenBlack : BreadColors.crumbWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.recipe.name,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Exit Kitchen Mode',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
              color: BreadColors.crustGold,
              minHeight: 6,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStepIndex + 1} of ${steps.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BreadColors.crustGoldDark,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BreadColors.crustGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      currentStep.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BreadColors.crustGoldDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Step Text
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentStep.text,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 26,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (currentStep.timeMinutes > 0) ...[
                          const SizedBox(height: 28),
                          StepTimerWidget(
                            secondsRemaining: _secondsRemaining,
                            isRunning: _isTimerRunning,
                            onPauseResume: _toggleTimer,
                            onReset: () {
                              setState(() {
                                _initTimerForStep(_currentStepIndex);
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Big Touch-Friendly Navigation Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDark ? BreadColors.toastSurface : BreadColors.crumbWarmGrey,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentStepIndex > 0 ? _prevStep : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? BreadColors.ovenCharcoal : Colors.white,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _currentStepIndex < steps.length - 1
                          ? _nextStep
                          : () => Navigator.pop(context),
                      icon: Icon(
                        _currentStepIndex < steps.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                      ),
                      label: Text(
                        _currentStepIndex < steps.length - 1
                            ? 'Next Step'
                            : 'Finish Bake',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BreadColors.crustGoldDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
