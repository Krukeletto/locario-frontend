import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../../shared/config/api_config.dart';
import '../../../shared/groups/pin_styles.dart';
import '../../../shared/groups/group_repository.dart';

class PinSelector extends StatefulWidget {
  const PinSelector({
    super.key,
    this.groupId,
    this.initialStyleKey,
    this.initialCustomUrl,
    this.repository,
    this.onChanged,
  });

  final String? groupId;
  final String? initialStyleKey;
  final String? initialCustomUrl;
  final GroupRepository? repository;
  final ValueChanged<({String? styleKey, String? customUrl})>? onChanged;

  @override
  State<PinSelector> createState() => _PinSelectorState();
}

class _PinSelectorState extends State<PinSelector> {
  String? _selectedStyleKey;
  String? _customUrl;
  bool _isUploading = false;

  late final GroupRepository _repository;

  bool get _isCustom => _customUrl != null && _customUrl!.isNotEmpty;
  bool get _hasGroupId => widget.groupId != null && widget.groupId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HttpGroupRepository();
    _selectedStyleKey = widget.initialStyleKey;
    _customUrl = widget.initialCustomUrl;
  }

  void _selectPin(String styleKey) {
    setState(() {
      _selectedStyleKey = styleKey;
      _customUrl = null;
    });
    widget.onChanged?.call((styleKey: styleKey, customUrl: null));
  }

  Future<void> _uploadCustomPin() async {
    if (!_hasGroupId) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final fileName = file.name;
    final ext = fileName.split('.').last.toLowerCase();
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };

    setState(() {
      _isUploading = true;
    });

    try {
      final accessToken = _getAccessToken();
      if (accessToken == null) {
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      final presigned = await _getPresignedUrl(
        groupId: widget.groupId!,
        fileName: fileName,
        contentType: contentType,
        fileSize: bytes.length,
        accessToken: accessToken,
      );

      await http.put(
        Uri.parse(presigned['uploadUrl'] as String),
        headers: {'Content-Type': contentType},
        body: bytes,
      );

      final group = await _repository.confirmMapPin(
        widget.groupId!,
        presigned['objectKey'] as String,
        contentType,
        accessToken: accessToken,
      );

      if (mounted) {
        setState(() {
          _selectedStyleKey = null;
          _customUrl = group.mapPinIconUrl;
          _isUploading = false;
        });
        widget.onChanged?.call((
          styleKey: null,
          customUrl: group.mapPinIconUrl,
        ));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie udało się przesłać ikony pina')),
          );
        }
      }
    }
  }

  Future<void> _deleteCustomPin() async {
    if (!_hasGroupId || _customUrl == null) return;

    try {
      final accessToken = _getAccessToken();
      if (accessToken == null) return;

      await _repository.deleteMapPin(widget.groupId!, accessToken: accessToken);

      if (mounted) {
        setState(() {
          _customUrl = null;
        });
        widget.onChanged?.call((styleKey: null, customUrl: null));
      }
    } catch (_) {}
  }

  String? _getAccessToken() {
    // Token is retrieved from the repository's internal logic.
    // For simplicity, return null and let the repository handle auth.
    return '';
  }

  Future<Map<String, dynamic>> _getPresignedUrl({
    required String groupId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required String accessToken,
  }) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/media/presigned-upload-url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'entityType': 'GROUP_MAP_PIN',
          'entityId': groupId,
          'fileName': fileName,
          'contentType': contentType,
          'fileSize': fileSize,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pin in PredefinedPin.all)
              _PinOption(
                icon: pin.icon,
                label: pin.label,
                isSelected: _selectedStyleKey == pin.styleKey && !_isCustom,
                onTap: () => _selectPin(pin.styleKey),
              ),
            if (_hasGroupId)
              _PinOption(
                icon: _isCustom
                    ? Icons.image_rounded
                    : Icons.add_photo_alternate_outlined,
                label: 'Własny',
                isSelected: _isCustom,
                isCustom: true,
                onTap: _isUploading ? null : _uploadCustomPin,
                isLoading: _isUploading,
              ),
          ],
        ),
        if (_isCustom && _customUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _customUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.image_rounded,
                      size: 44,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _deleteCustomPin,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Usuń'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PinOption extends StatelessWidget {
  const _PinOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isCustom = false,
    this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
              ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
