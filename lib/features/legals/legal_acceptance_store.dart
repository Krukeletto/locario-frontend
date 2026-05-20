abstract class LegalAcceptanceStore {
  Future<int> getAcceptedTermsVersion(String userId);

  Future<int> getAcceptedPrivacyVersion(String userId);

  Future<void> acceptTerms(String userId, int version);

  Future<void> acceptPrivacy(String userId, int version);
}
