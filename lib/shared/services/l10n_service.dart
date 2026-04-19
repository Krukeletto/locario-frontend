import 'package:locario/l10n/app_localizations.dart';

class L10nService {
  L10nService._();

  static AppLocalizations? _instance;

  /// Returns the current [AppLocalizations].
  ///
  /// Throws a [StateError] if the service has not been initialized.
  static AppLocalizations get l10n {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'L10nService has not been initialized. '
        'Ensure that L10nService.update(AppLocalizations.of(context)!) is called '
        'in the MaterialApp builder.',
      );
    }
    return instance;
  }

  /// Updates the current [AppLocalizations] instance.
  static void update(AppLocalizations instance) {
    _instance = instance;
  }

  /// Initializes the service with an [AppLocalizations] instance.
  static void init(AppLocalizations instance) => update(instance);
}
