import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'l10n_service.dart';

enum FeedbackMessage {
  loginSuccess,
  logoutSuccess,
  loginInvalidCredentials,
  networkError,
  featureComingSoon,
  eventCreated,
  eventSaveSuccess,
  eventRemoveSuccess,
  eventJoinSuccess,
  eventLeaveSuccess,
  eventJoinError,
  eventPublishSuccess,
  eventPublishError,
  eventReviewSuccess,
  eventReviewError,
  unknownError,
}

enum FeedbackStyle { success, error, info }

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FeedbackService {
  FeedbackService._();

  static DateTime? _lastMessageTime;
  static FeedbackMessage? _lastMessage;

  @visibleForTesting
  static void resetForTests() {
    _lastMessageTime = null;
    _lastMessage = null;
  }

  /// Shows a success feedback message.
  static void showSuccess(FeedbackMessage message) {
    _showFeedback(message, style: FeedbackStyle.success);
  }

  /// Shows an error feedback message.
  static void showError(FeedbackMessage message) {
    _showFeedback(message, style: FeedbackStyle.error);
  }

  /// Shows an info feedback message.
  static void showInfo(FeedbackMessage message) {
    _showFeedback(message, style: FeedbackStyle.info);
  }

  /// Internal method to show feedback using [L10nService] and [rootScaffoldMessengerKey].
  static void _showFeedback(
    FeedbackMessage message, {
    required FeedbackStyle style,
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastMessageTime != null &&
        now.difference(_lastMessageTime!) < const Duration(seconds: 1)) {
      return;
    }

    _lastMessage = message;
    _lastMessageTime = now;

    final l10n = L10nService.l10n;
    final text = _getMessageText(l10n, message);

    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    if (style == FeedbackStyle.error) {
      messenger.removeCurrentSnackBar();
    }

    final theme = Theme.of(messenger.context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: _getBackgroundColor(theme.colorScheme, style),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static String _getMessageText(
    AppLocalizations l10n,
    FeedbackMessage message,
  ) {
    return switch (message) {
      FeedbackMessage.loginSuccess => l10n.authLoginSuccess,
      FeedbackMessage.logoutSuccess => l10n.authLogoutSuccess,
      FeedbackMessage.loginInvalidCredentials =>
        l10n.authLoginErrorInvalidCredentials,
      FeedbackMessage.networkError => l10n.networkError,
      FeedbackMessage.featureComingSoon => l10n.featureComingSoon,
      FeedbackMessage.eventCreated => l10n.hubCreateEventCreatedSuccess,
      FeedbackMessage.eventSaveSuccess => l10n.eventSaveSuccess,
      FeedbackMessage.eventRemoveSuccess => l10n.eventRemoveSuccess,
      FeedbackMessage.eventJoinSuccess => l10n.eventJoinSuccess,
      FeedbackMessage.eventLeaveSuccess => l10n.eventLeaveSuccess,
      FeedbackMessage.eventJoinError => l10n.eventJoinError,
      FeedbackMessage.eventPublishSuccess => l10n.eventPublishSuccess,
      FeedbackMessage.eventPublishError => l10n.eventPublishError,
      FeedbackMessage.eventReviewSuccess => l10n.eventReviewSuccess,
      FeedbackMessage.eventReviewError => l10n.eventReviewError,
      FeedbackMessage.unknownError => l10n.exploreErrorUnknownTitle,
    };
  }

  static Color _getBackgroundColor(
    ColorScheme colorScheme,
    FeedbackStyle style,
  ) {
    return switch (style) {
      FeedbackStyle.success => colorScheme.primary,
      FeedbackStyle.error => colorScheme.error,
      FeedbackStyle.info => colorScheme.tertiary,
    };
  }
}
