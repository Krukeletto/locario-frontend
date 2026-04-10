import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_header/app_header.dart';
import 'app_header/app_header_controller.dart';
import 'app_header/app_header_scope.dart';
import 'hub/hub_action_item.dart';
import 'hub/hub_panel.dart';
import 'nav/app_bottom_nav.dart';
import 'nav/app_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.hubItems,
    required this.showHeader,
    required this.showViewToggle,
  });

  final StatefulNavigationShell navigationShell;
  final List<HubActionItem> hubItems;
  final bool showHeader;
  final bool showViewToggle;

  @override
  State<AppShell> createState() => _AppShellState();
}

// Main app shell widget, which includes the bottom navigation bar and the hub layer.
class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  bool _hubOpen = false;
  late final AnimationController _hubController;
  late final AppHeaderController _appHeaderController;

  @override
  void initState() {
    super.initState();
    _appHeaderController = AppHeaderController();
    _hubController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
            widget.navigationShell.currentIndex &&
        _hubOpen) {
      _closeHub();
    }
  }

  @override
  void dispose() {
    _appHeaderController.dispose();
    _hubController.dispose();
    super.dispose();
  }

  void _handleTabSelected(AppTab tab) {
    final targetIndex = switch (tab) {
      AppTab.explore => 0,
      AppTab.inbox => 1,
      AppTab.profile => 2,
    };

    widget.navigationShell.goBranch(targetIndex);
    if (_hubOpen) {
      _closeHub();
    }
  }

  void _handleHubToggle() {
    if (_hubOpen) {
      _closeHub();
      return;
    }

    setState(() {
      _hubOpen = true;
    });
    _hubController.forward(from: 0);
  }

  void _handleHubItemSelected(HubActionItem item) {
    _closeHub();
    context.push(item.routePath);
  }

  void _closeHub() {
    if (!_hubOpen && _hubController.status == AnimationStatus.dismissed) {
      return;
    }

    setState(() {
      _hubOpen = false;
    });
    _hubController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = switch (widget.navigationShell.currentIndex) {
      0 => AppTab.explore,
      1 => AppTab.inbox,
      2 => AppTab.profile,
      _ => AppTab.explore,
    };
    const hubPanelBottom = 16.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_hubController, _appHeaderController]),
        builder: (context, child) {
          final showHubLayer = _hubOpen || _hubController.value > 0;

          return AppHeaderScope(
            controller: _appHeaderController,
            child: Column(
              children: [
                if (widget.showHeader)
                  SafeArea(
                    bottom: false,
                    child: AppHeader(
                      selectedView: _appHeaderController.selectedView,
                      onViewChanged: _appHeaderController.setSelectedView,
                      showViewToggle: widget.showViewToggle,
                    ),
                  ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: widget.navigationShell,
                        ),
                      ),
                      if (showHubLayer)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _closeHub,
                            child: Container(
                              color: Colors.black.withValues(
                                alpha: 0.10 * _hubController.value,
                              ),
                            ),
                          ),
                        ),
                      if (showHubLayer)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: hubPanelBottom,
                          child: Builder(
                            builder: (context) {
                              final panelProgress = Curves.easeOutCubic
                                  .transform(
                                    Interval(
                                      0.18,
                                      1,
                                    ).transform(_hubController.value),
                                  );

                              return Transform.translate(
                                offset: Offset(0, (1 - panelProgress) * 24),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    heightFactor: panelProgress
                                        .clamp(0.001, 1)
                                        .toDouble(),
                                    child: Opacity(
                                      opacity: panelProgress,
                                      child: HubPanel(
                                        items: widget.hubItems,
                                        onItemSelected: _handleHubItemSelected,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        activeTab: activeTab,
        hubOpen: _hubOpen,
        onTabSelected: _handleTabSelected,
        onHubToggle: _handleHubToggle,
      ),
    );
  }
}
