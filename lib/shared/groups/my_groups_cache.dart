import 'group_models.dart';
import 'group_repository.dart';

class MyGroupsCache {
  MyGroupsCache._();

  static List<Group>? _myGroups;

  static List<Group>? get myGroups => _myGroups;
  static bool get hasValue => _myGroups != null;
  static bool get isNotEmpty => _myGroups != null && _myGroups!.isNotEmpty;

  static Future<void> prefetch({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    if (_myGroups != null) return;
    try {
      final repo = HttpGroupRepository();
      final groups = await repo.fetchMyGroups(
        accessToken: accessToken,
        tokenType: tokenType,
      );
      _myGroups = groups.toList();
    } catch (_) {}
  }

  static void set(List<Group> groups) {
    _myGroups = groups.toList();
  }

  static void invalidate() {
    _myGroups = null;
  }
}
