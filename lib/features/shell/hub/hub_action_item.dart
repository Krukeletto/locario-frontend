import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

class HubActionItem {
  const HubActionItem({
    required this.id,
    required this.icon,
    required this.routePath,
    this.accentColor,
    this.isPrimary = false,
    this.isEnabled = true,
  });

  final String id;
  final String icon;
  final String routePath;
  final int? accentColor;
  final bool isPrimary;
  final bool isEnabled;

  String title(AppLocalizations l10n) {
    switch (id) {
      case 'create-event':
        return l10n.hubCreateEventTitle;
      case 'community':
        return l10n.hubCommunityTitle;
      case 'friends':
        return l10n.hubFriendsTitle;
      default:
        return id;
    }
  }

  String subtitle(AppLocalizations l10n) {
    switch (id) {
      case 'create-event':
        return l10n.hubCreateEventSubtitle;
      case 'community':
        return l10n.hubCommunitySubtitle;
      case 'friends':
        return l10n.hubFriendsSubtitle;
      default:
        return id;
    }
  }

  IconData get iconData {
    switch (icon) {
      case 'add_box':
        return Icons.add_box_outlined;
      case 'groups':
        return Icons.groups_2_outlined;
      case 'person_add':
        return Icons.person_add_alt_1_rounded;
      case 'group_work':
        return Icons.group_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.apps_rounded;
    }
  }

  Color? get accent => accentColor == null ? null : Color(accentColor!);
}
