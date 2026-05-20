import 'package:flutter/foundation.dart';

import '../../shared/auth/session_controller.dart';
import 'legal_acceptance_store.dart';
import 'legal_versions.dart';

class LegalController extends ChangeNotifier {
  LegalController({
    required LegalAcceptanceStore store,
    required SessionController sessionController,
  }) : _store = store,
       _sessionController = sessionController {
    _sessionController.addListener(_onSessionChanged);
  }

  final LegalAcceptanceStore _store;
  final SessionController _sessionController;

  int _acceptedTermsVersion = 0;
  int _acceptedPrivacyVersion = 0;
  bool _isLoading = true;

  bool _isAuthenticated() => _sessionController.isAuthenticated;

  bool get isAcceptanceRequired {
    if (_isLoading) {
      return false;
    }
    if (!_isAuthenticated()) {
      return false;
    }
    return _acceptedTermsVersion < LegalVersions.termsVersion ||
        _acceptedPrivacyVersion < LegalVersions.privacyVersion;
  }

  bool get isLoading => _isLoading;

  Future<void> load() async {
    if (!_isAuthenticated() || _sessionController.profile == null) {
      _acceptedTermsVersion = 0;
      _acceptedPrivacyVersion = 0;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final userId = _sessionController.profile!.id;
    final terms = await _store.getAcceptedTermsVersion(userId);
    final privacy = await _store.getAcceptedPrivacyVersion(userId);
    _acceptedTermsVersion = terms;
    _acceptedPrivacyVersion = privacy;
    _isLoading = false;
    notifyListeners();
  }

  void _onSessionChanged() {
    if (!_sessionController.isLoading) {
      load();
    }
  }

  Future<void> acceptAll() async {
    final userId = _sessionController.profile?.id;
    if (userId == null) {
      return;
    }

    await _store.acceptTerms(userId, LegalVersions.termsVersion);
    await _store.acceptPrivacy(userId, LegalVersions.privacyVersion);
    _acceptedTermsVersion = LegalVersions.termsVersion;
    _acceptedPrivacyVersion = LegalVersions.privacyVersion;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}
