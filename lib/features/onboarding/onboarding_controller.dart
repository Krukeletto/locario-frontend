import 'package:flutter/foundation.dart';

import '../../app/settings/app_settings_store.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController({required AppSettingsStore settingsStore})
    : _settingsStore = settingsStore;

  final AppSettingsStore _settingsStore;

  bool _isLoading = true;
  bool _isCompleted = false;

  bool get isLoading => _isLoading;
  bool get isCompleted => _isCompleted;

  Future<void> load() async {
    _isCompleted = await _settingsStore.loadOnboardingCompleted();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> complete() async {
    await _settingsStore.saveOnboardingCompleted(true);
    _isCompleted = true;
    _isLoading = false;
    notifyListeners();
  }
}
