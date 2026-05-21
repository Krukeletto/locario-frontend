import 'consent_type.dart';

abstract class ConsentsStore {
  Future<bool> isGranted(ConsentType type);

  Future<void> setGranted(ConsentType type, bool granted);

  Future<Map<ConsentType, bool>> loadAll();
}
