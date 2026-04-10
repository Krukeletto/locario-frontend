import 'package:flutter/material.dart';

class HubActionItem {
  const HubActionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routePath,
    this.accentColor,
    this.isPrimary = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String routePath;
  final int? accentColor;
  final bool isPrimary;

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
