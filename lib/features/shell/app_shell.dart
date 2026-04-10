import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';
import 'app_tab.dart';
import 'more_action_item.dart';
import 'more_panel.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.moreItems,
  });

  final StatefulNavigationShell navigationShell;
  final List<MoreActionItem> moreItems;

  @override
  State<AppShell> createState() => _AppShellState();
}

// Main app shell widget, which includes the bottom navigation bar and the "more" layer.
class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  bool _moreOpen = false;
  late final AnimationController _moreController;

  bool get _showMoreLayer =>
      _moreOpen ||
      _moreController.status == AnimationStatus.forward ||
      _moreController.status == AnimationStatus.reverse;

  @override
  void initState() {
    super.initState();
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
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: widget.navigationShell),
          // Dismiss backdrop shown only while the More layer is animating/visible.
          if (_showMoreLayer)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _moreController,
                builder: (context, child) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeMore,
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: 0.10 * _moreController.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_showMoreLayer)
            Positioned(
              left: 16,
              right: 16,
              bottom: morePanelBottom,
              child: AnimatedBuilder(
                animation: _moreController,
                builder: (context, child) {
                  final panelProgress = Curves.easeOutCubic.transform(
                    Interval(0.18, 1).transform(_moreController.value),
                  );

                  return Transform.translate(
                    offset: Offset(0, (1 - panelProgress) * 24),
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: panelProgress.clamp(0.001, 1).toDouble(),
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
      bottomNavigationBar: AppBottomNav(
        activeTab: activeTab,
        moreOpen: _moreOpen,
        onTabSelected: _handleTabSelected,
        onMoreToggle: _handleMoreToggle,
      ),
    );
  }
}
