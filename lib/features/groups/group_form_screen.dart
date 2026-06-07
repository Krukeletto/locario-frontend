import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/events/category_scope.dart';
import '../../shared/groups/group_models.dart';
import '../../shared/groups/group_repository.dart';
import '../../shared/groups/group_scope.dart';
import '../../shared/services/feedback_service.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key, this.groupId, GroupRepository? repository})
    : _repository = repository;

  final String? groupId;
  final GroupRepository? _repository;

  bool get isEditing => groupId != null;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  late final GroupRepository _repository;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _iconUrlController = TextEditingController();
  final _mapPinIconUrlController = TextEditingController();
  final _mapPinStyleController = TextEditingController();

  GroupVisibility _visibility = GroupVisibility.public;
  String? _categoryId;
  bool _showAdvanced = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? HttpGroupRepository();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _load();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _avatarUrlController.dispose();
    _iconUrlController.dispose();
    _mapPinIconUrlController.dispose();
    _mapPinStyleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.groupId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ctrl = GroupScope.of(context);
      await ctrl.loadGroupDetail(widget.groupId!);
      final group = ctrl.detailGroup;
      if (group != null) {
        _nameController.text = group.name;
        _descriptionController.text = group.description ?? '';
        _avatarUrlController.text = group.avatarUrl ?? '';
        _iconUrlController.text = group.iconUrl ?? '';
        _mapPinIconUrlController.text = group.mapPinIconUrl ?? '';
        _mapPinStyleController.text = group.mapPinStyle ?? '';
        _visibility = group.visibility;
        _categoryId = group.categoryId;
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      FeedbackService.showError(FeedbackMessage.unknownError);
    }
  }

  bool _canEditCurrentUser() {
    final session = AuthScope.of(context);
    final profile = session.profile;
    final group = GroupScope.maybeOf(context)?.detailGroup;
    if (profile == null || group == null) return !widget.isEditing;
    return profile.admin ||
        group.ownerUserId == profile.id ||
        group.currentUserRole == GroupRole.admin;
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final session = AuthScope.of(context);
    final tokens = session.tokens;
    if (tokens == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final saved = widget.isEditing
          ? await _repository.updateGroup(
              widget.groupId!,
              GroupUpdateRequest(
                name: _nameController.text.trim(),
                description: _emptyToNull(_descriptionController.text),
                categoryId: _categoryId,
                visibility: _visibility,
                avatarUrl: _emptyToNull(_avatarUrlController.text),
                iconUrl: _emptyToNull(_iconUrlController.text),
                mapPinIconUrl: _emptyToNull(_mapPinIconUrlController.text),
                mapPinStyle: _emptyToNull(_mapPinStyleController.text),
              ),
              accessToken: tokens.accessToken,
              tokenType: tokens.tokenType,
            )
          : await _repository.createGroup(
              GroupCreateRequest(
                name: _nameController.text.trim(),
                description: _emptyToNull(_descriptionController.text),
                categoryId: _categoryId,
                visibility: _visibility,
                avatarUrl: _emptyToNull(_avatarUrlController.text),
                iconUrl: _emptyToNull(_iconUrlController.text),
                mapPinIconUrl: _emptyToNull(_mapPinIconUrlController.text),
                mapPinStyle: _emptyToNull(_mapPinStyleController.text),
              ),
              accessToken: tokens.accessToken,
              tokenType: tokens.tokenType,
            );

      if (!mounted) {
        return;
      }
      if (Navigator.of(context).canPop()) {
        context.pop(saved);
      } else {
        context.go('/groups/${saved.id}');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      FeedbackService.showError(FeedbackMessage.unknownError);
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final categories =
        CategoryScope.maybeOf(context)?.categories ?? const <Category>[];

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(child: CircularProgressIndicator(color: scheme.primary)),
      );
    }

    if (widget.isEditing && !_canEditCurrentUser()) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            l10n.groupsEditForbidden,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditing ? l10n.groupsEditTitle : l10n.groupsCreateTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    key: const Key('group-form-name'),
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldName,
                    ),
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) {
                        return l10n.groupsValidationNameRequired;
                      }
                      if (text.length > 255) {
                        return l10n.groupsValidationNameTooLong;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('group-form-description'),
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldDescription,
                    ),
                    validator: (value) {
                      if ((value ?? '').length > 5000) {
                        return l10n.groupsValidationDescriptionTooLong;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    key: const Key('group-form-category'),
                    initialValue: _categoryId,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldCategory,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.groupsCategoryNone),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem<String?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _categoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<GroupVisibility>(
                    segments: [
                      ButtonSegment<GroupVisibility>(
                        value: GroupVisibility.public,
                        label: Text(l10n.groupsVisibilityPublic),
                      ),
                      ButtonSegment<GroupVisibility>(
                        value: GroupVisibility.private,
                        label: Text(l10n.groupsVisibilityPrivate),
                      ),
                    ],
                    selected: {_visibility},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _visibility = selection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: _showAdvanced,
                onExpansionChanged: (value) {
                  setState(() {
                    _showAdvanced = value;
                  });
                },
                title: Text(
                  l10n.groupsAdvancedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                subtitle: Text(
                  l10n.groupsAdvancedSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _avatarUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldAvatarUrl,
                    ),
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _iconUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldIconUrl,
                    ),
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mapPinIconUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldMapPinIconUrl,
                    ),
                    validator: _validateUrl,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mapPinStyleController,
                    decoration: InputDecoration(
                      labelText: l10n.groupsFieldMapPinStyle,
                    ),
                    validator: (value) {
                      if ((value ?? '').length > 50) {
                        return l10n.groupsValidationMapPinStyleTooLong;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isEditing
                          ? l10n.groupsSaveChanges
                          : l10n.groupsCreateSubmit,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    if (text.length > 2048) {
      return AppLocalizations.of(context).groupsValidationUrlTooLong;
    }
    final uri = Uri.tryParse(text);
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      return AppLocalizations.of(context).groupsValidationUrlInvalid;
    }
    return null;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.24)),
      ),
      child: child,
    );
  }
}
