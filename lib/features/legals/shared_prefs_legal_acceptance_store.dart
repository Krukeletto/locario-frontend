import 'package:shared_preferences/shared_preferences.dart';

import 'legal_acceptance_store.dart';

class SharedPrefsLegalAcceptanceStore implements LegalAcceptanceStore {
  const SharedPrefsLegalAcceptanceStore();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _termsKey(String userId) => 'legal.$userId.termsVersion';
  String _privacyKey(String userId) => 'legal.$userId.privacyVersion';

  @override
  Future<int> getAcceptedTermsVersion(String userId) async {
    return (await _prefs).getInt(_termsKey(userId)) ?? 0;
  }

  @override
  Future<int> getAcceptedPrivacyVersion(String userId) async {
    return (await _prefs).getInt(_privacyKey(userId)) ?? 0;
  }

  @override
  Future<void> acceptTerms(String userId, int version) async {
    await (await _prefs).setInt(_termsKey(userId), version);
  }

  @override
  Future<void> acceptPrivacy(String userId, int version) async {
    await (await _prefs).setInt(_privacyKey(userId), version);
  }
}
