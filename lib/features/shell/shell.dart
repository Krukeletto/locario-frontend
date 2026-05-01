import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/auth/auth_scope.dart';
import 'header/header.dart';
import 'header/header_controller.dart';
import 'header/header_scope.dart';
import 'hub/hub_action_item.dart';
import 'hub/hub_panel.dart';
import 'nav/bottom_nav.dart';
import 'nav/tab.dart';

class Shell extends StatefulWidget {
  const Shell({
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
  State<Shell> createState() => _ShellState();
}

// Main app shell widget, which includes the bottom navigation bar and the hub layer.
class _ShellState extends State<Shell> with SingleTickerProviderStateMixin {
  bool _hubOpen = false;
  late final AnimationController _hubController;
  late final ShellHeaderController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = ShellHeaderController();
    _hubController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didUpdateWidget(covariant Shell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
            widget.navigationShell.currentIndex &&
        _hubOpen) {
      _closeHub();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _hubController.dispose();
    super.dispose();
  }

  void _handleTabSelected(ShellTab tab) {
    final sessionController = AuthScope.maybeOf(context);
    if (tab == ShellTab.saved &&
        sessionController != null &&
        !sessionController.isAuthenticated) {
      final returnLocation = switch (widget.navigationShell.currentIndex) {
        0 => ShellTab.explore.routePath,
        1 => ShellTab.saved.routePath,
        2 => ShellTab.profile.routePath,
        _ => ShellTab.explore.routePath,
      };

      context.push(
        '/auth/login?from=${Uri.encodeComponent(returnLocation)}&target=${Uri.encodeComponent(tab.routePath)}',
      );
      return;
    }

    final targetIndex = switch (tab) {
      ShellTab.explore => 0,
      ShellTab.saved => 1,
      ShellTab.profile => 2,
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
    final theme = Theme.of(context);
    final activeTab = switch (widget.navigationShell.currentIndex) {
      0 => ShellTab.explore,
      1 => ShellTab.saved,
      2 => ShellTab.profile,
      _ => ShellTab.explore,
    };
    const hubPanelBottom = 16.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_hubController, _headerController]),
        builder: (context, child) {
          final showHubLayer = _hubOpen || _hubController.value > 0;

          return ShellHeaderScope(
            controller: _headerController,
            child: Column(
              children: [
                if (widget.showHeader)
                  SafeArea(
                    bottom: false,
                    child: ShellHeader(
                      selectedView: _headerController.selectedView,
                      onViewChanged: _headerController.setSelectedView,
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
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 4 * _hubController.value,
                                sigmaY: 4 * _hubController.value,
                              ),
                              child: Container(
                                color:
                                    (theme.brightness == Brightness.dark
                                            ? Colors.black
                                            : theme.colorScheme.primary)
                                        .withValues(
                                          alpha:
                                              (theme.brightness ==
                                                      Brightness.dark
                                                  ? 0.34
                                                  : 0.12) *
                                              _hubController.value,
                                        ),
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
      bottomNavigationBar: ShellBottomNav(
        activeTab: activeTab,
        hubOpen: _hubOpen,
        onTabSelected: _handleTabSelected,
        onHubToggle: _handleHubToggle,
      ),
    );
  }
}
