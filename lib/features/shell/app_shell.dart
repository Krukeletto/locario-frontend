import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_header/app_header.dart';
import 'app_header/app_header_controller.dart';
import 'app_header/app_header_scope.dart';
import 'nav/app_bottom_nav.dart';
import 'nav/app_tab.dart';
import 'more/more_action_item.dart';
import 'more/more_panel.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.moreItems,
    required this.showHeader,
    required this.showViewToggle,
  });

  final StatefulNavigationShell navigationShell;
  final List<MoreActionItem> moreItems;
  final bool showHeader;
  final bool showViewToggle;

  @override
  State<AppShell> createState() => _AppShellState();
}

// Main app shell widget, which includes the bottom navigation bar and the "more" layer.
class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  bool _moreOpen = false;
  late final AnimationController _moreController;
  late final AppHeaderController _appHeaderController;

  @override
  void initState() {
    super.initState();
    _appHeaderController = AppHeaderController();
    _moreController = AnimationController(
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
        _moreOpen) {
      _closeMore();
    }
  }

  @override
  void dispose() {
    _appHeaderController.dispose();
    _moreController.dispose();
    super.dispose();
  }

  void _handleTabSelected(AppTab tab) {
    final targetIndex = switch (tab) {
      AppTab.explore => 0,
      AppTab.saved => 1,
      AppTab.inbox => 2,
      AppTab.profile => 3,
    };

    widget.navigationShell.goBranch(targetIndex);
    if (_moreOpen) {
      _closeMore();
    }
  }

  void _handleMoreToggle() {
    if (_moreOpen) {
      _closeMore();
      return;
    }

    setState(() {
      _moreOpen = true;
    });
    _moreController.forward(from: 0);
  }

  void _handleMoreItemSelected(MoreActionItem item) {
    _closeMore();
    context.push(item.routePath);
  }

  void _closeMore() {
    if (!_moreOpen && _moreController.status == AnimationStatus.dismissed) {
      return;
    }

    setState(() {
      _moreOpen = false;
    });
    _moreController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = switch (widget.navigationShell.currentIndex) {
      0 => AppTab.explore,
      1 => AppTab.saved,
      2 => AppTab.inbox,
      3 => AppTab.profile,
      _ => AppTab.explore,
    };
    const morePanelBottom = 16.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_moreController, _appHeaderController]),
        builder: (context, child) {
          final showMoreLayer = _moreOpen || _moreController.value > 0;

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
                      if (showMoreLayer)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _closeMore,
                            child: Container(
                              color: Colors.black.withValues(
                                alpha: 0.10 * _moreController.value,
                              ),
                            ),
                          ),
                        ),
                      if (showMoreLayer)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: morePanelBottom,
                          child: Builder(
                            builder: (context) {
                              final panelProgress = Curves.easeOutCubic
                                  .transform(
                                    Interval(
                                      0.18,
                                      1,
                                    ).transform(_moreController.value),
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
                                      child: MorePanel(
                                        items: widget.moreItems,
                                        onItemSelected: _handleMoreItemSelected,
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
        moreOpen: _moreOpen,
        onTabSelected: _handleTabSelected,
        onMoreToggle: _handleMoreToggle,
      ),
    );
  }
}
