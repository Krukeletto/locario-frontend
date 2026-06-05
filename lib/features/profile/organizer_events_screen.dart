import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import '../../shared/events/event_repository.dart';
import '../../shared/widgets/state_panel.dart';
import '../explore/models.dart';

class OrganizerEventsScreen extends StatefulWidget {
  const OrganizerEventsScreen({super.key, EventRepository? eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository? _eventRepository;

  @override
  State<OrganizerEventsScreen> createState() => _OrganizerEventsScreenState();
}

class _OrganizerEventsScreenState extends State<OrganizerEventsScreen> {
  late final EventRepository _eventRepository;
  List<ExploreEvent> _events = const [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = AuthScope.of(context);
    if (session.tokens == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventRepository.fetchOrganizerEvents(
        accessToken: session.tokens!.accessToken,
        tokenType: session.tokens!.tokenType,
      );
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: scheme.primary,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          l10n.profileMyEventsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? StatePanel.loading(
              title: l10n.profileMyEventsTitle,
              subtitle: l10n.profileMyEventsSubtitle,
            )
          : _error != null
          ? StatePanel.error(
              title: l10n.profileEventHistoryTitle,
              subtitle: l10n.groupsErrorSubtitle,
              retryLabel: l10n.exploreRetryButton,
              onRetry: _load,
            )
          : _events.isEmpty
          ? StatePanel.empty(
              title: l10n.profileMyEventsTitle,
              subtitle: l10n.profileMyEventsSubtitle,
              customContent: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FilledButton.icon(
                  onPressed: () => context.push('/hub/create-event'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.profileOrganizerCreateEvent),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(event.title),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/events/${event.id}'),
                  ),
                );
              },
            ),
    );
  }
}
