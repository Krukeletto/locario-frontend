import 'package:shared_preferences/shared_preferences.dart';

import 'consent_type.dart';
import 'consents_store.dart';

class SharedPrefsConsentsStore implements ConsentsStore {
  const SharedPrefsConsentsStore();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<bool> isGranted(ConsentType type) async {
    return (await _prefs).getBool(type.prefsKey) ?? false;
  }

  @override
  Future<void> setGranted(ConsentType type, bool granted) async {
    await (await _prefs).setBool(type.prefsKey, granted);
  }

  @override
  Future<Map<ConsentType, bool>> loadAll() async {
    final prefs = await _prefs;
    final result = <ConsentType, bool>{};
    for (final type in ConsentType.values) {
      result[type] = prefs.getBool(type.prefsKey) ?? false;
    }
    return result;
  }
}
