import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/recipe_detail.dart';
import '../data/services/bakers_api_service.dart';
import '../data/services/storage_service.dart';

/// Provider managing active recipe details, ingredient batch scaling, and baking timers.
class RecipeDetailProvider extends ChangeNotifier {
  final BakersApiService _apiService;

  RecipeDetailProvider({BakersApiService? apiService})
      : _apiService = apiService ?? BakersApiService();

  RecipeDetail? _recipe;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineFallback = false;

  // Interactive baking features
  double _scaleMultiplier = 1.0;
  final Set<int> _checkedIngredientIds = {};
  final Set<int> _completedStepIds = {};

  // Step countdown timer
  int? _activeTimerStepId;
  int _timerSecondsRemaining = 0;
  bool _isTimerRunning = false;
  Timer? _countdownTimer;

  RecipeDetail? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineFallback => _isOfflineFallback;

  double get scaleMultiplier => _scaleMultiplier;
  Set<int> get checkedIngredientIds => _checkedIngredientIds;
  Set<int> get completedStepIds => _completedStepIds;

  int? get activeTimerStepId => _activeTimerStepId;
  int get timerSecondsRemaining => _timerSecondsRemaining;
  bool get isTimerRunning => _isTimerRunning;

  /// Load recipe detail with offline storage fallback
  Future<void> loadRecipe(
    int recipeId,
    String baseUrl, {
    StorageService? storageService,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isOfflineFallback = false;
    _scaleMultiplier = 1.0;
    _checkedIngredientIds.clear();
    _completedStepIds.clear();
    _cancelTimer();
    notifyListeners();

    try {
      final detail = await _apiService.fetchRecipeDetail(baseUrl, recipeId);
      _recipe = detail;
      _isOfflineFallback = false;
    } catch (e) {
      // Check local offline storage
      final offline = storageService?.getOfflineRecipeDetail(recipeId);
      if (offline != null) {
        _recipe = offline;
        _isOfflineFallback = true;
        _errorMessage = null;
      } else {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change scaling multiplier (e.g. 0.5x, 1x, 1.5x, 2x)
  void setScaleMultiplier(double multiplier) {
    if (multiplier <= 0) return;
    _scaleMultiplier = multiplier;
    notifyListeners();
  }

  /// Toggle ingredient checked status (mise en place prep)
  void toggleIngredientChecked(int ingredientId) {
    if (_checkedIngredientIds.contains(ingredientId)) {
      _checkedIngredientIds.remove(ingredientId);
    } else {
      _checkedIngredientIds.add(ingredientId);
    }
    notifyListeners();
  }

  /// Toggle step completed status
  void toggleStepCompleted(int stepId) {
    if (_completedStepIds.contains(stepId)) {
      _completedStepIds.remove(stepId);
    } else {
      _completedStepIds.add(stepId);
    }
    notifyListeners();
  }

  /// Reset all prep checks
  void resetChecklist() {
    _checkedIngredientIds.clear();
    _completedStepIds.clear();
    notifyListeners();
  }

  // --- Step Countdown Timer ---

  void startStepTimer(int stepId, double minutes) {
    _cancelTimer();
    _activeTimerStepId = stepId;
    _timerSecondsRemaining = (minutes * 60).round();
    _isTimerRunning = true;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSecondsRemaining > 0) {
        _timerSecondsRemaining--;
        notifyListeners();
      } else {
        _isTimerRunning = false;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void pauseResumeTimer() {
    if (_countdownTimer == null || !_isTimerRunning) {
      if (_timerSecondsRemaining > 0) {
        _isTimerRunning = true;
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timerSecondsRemaining > 0) {
            _timerSecondsRemaining--;
            notifyListeners();
          } else {
            _isTimerRunning = false;
            timer.cancel();
            notifyListeners();
          }
        });
      }
    } else {
      _isTimerRunning = false;
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
    notifyListeners();
  }

  void resetTimer() {
    _cancelTimer();
    _activeTimerStepId = null;
    _timerSecondsRemaining = 0;
    _isTimerRunning = false;
    notifyListeners();
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
