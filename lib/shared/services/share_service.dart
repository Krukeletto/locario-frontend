import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';

class ShareService {
  /// Returns a deep link URI that the app handles via go_router.
  ///
  /// The HTTPS URL `https://locario-events.web.app/events/<id>` is registered
  /// in the native manifests (AndroidManifest.xml / Info.plist) as an App Link /
  /// Universal Link. This allows the app to open directly from a shared link,
  /// or fall back to a web landing page if the app is not installed.
  static String getEventUrl(String eventId) {
    return 'https://locario-events.web.app/events/$eventId';
  }

  /// Opens the system share sheet for the given event.
  ///
  /// The shared text contains the deep link so that recipients with the app
  /// installed are taken directly to the event. The system sheet provides its
  /// own copy-link and platform-specific send options.
  static Future<void> shareEvent({
    required String eventId,
    required String title,
    required AppLocalizations l10n,
  }) async {
    final url = getEventUrl(eventId);
    final message = l10n.shareEventMessage(title, url);
    await SharePlus.instance.share(ShareParams(text: message, subject: title));
  }
}
