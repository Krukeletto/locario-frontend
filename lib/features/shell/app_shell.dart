import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';
import 'app_tab.dart';
import 'more_action_item.dart';
import 'more_panel.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.moreItems,
    required this.child,
  });

  final String location;
  final List<MoreActionItem> moreItems;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

// Main app shell widget, which includes the bottom navigation bar and the "more" layer.
class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  static const double _connectorHeight = 72;
  static const double _connectorSeamOverlap = 2;
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
    if (oldWidget.location != widget.location && _moreOpen) {
      _closeMore();
    }
  }

  @override
  void dispose() {
    _moreController.dispose();
    super.dispose();
  }

  void _handleTabSelected(AppTab tab) {
    if (tab.routePath != widget.location) {
      context.go(tab.routePath);
    }
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
    final activeTab = AppTab.fromLocation(widget.location);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final moreCompositeBottom = safeBottom - (_connectorHeight - 18);

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: widget.child),
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
              bottom: moreCompositeBottom,
              // Composite popup: panel + connector, both driven by one controller.
              child: AnimatedBuilder(
                animation: _moreController,
                builder: (context, child) {
                  final connectorProgress = Curves.easeOutCubic.transform(
                    _moreController.value,
                  );
                  final panelProgress = Curves.easeOutCubic.transform(
                    Interval(0.18, 1).transform(_moreController.value),
                  );

                  return Transform.translate(
                    offset: Offset(0, (1 - panelProgress) * 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Panel reveal via clipping + opacity to avoid overflow jumps.
                        ClipRect(
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
                        Transform.translate(
                          offset: const Offset(0, -_connectorSeamOverlap),
                          // Connector grows from top to keep seam with panel clean.
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: connectorProgress
                                  .clamp(0.001, 1)
                                  .toDouble(),
                              child: Opacity(
                                opacity: connectorProgress,
                                child: const _MoreConnector(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: _connectorSeamOverlap),
                      ],
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

class _MoreConnector extends StatelessWidget {
  const _MoreConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: CustomPaint(
        painter: _MoreConnectorPainter(
          color: const Color(0xFFF7F8EF),
          borderColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _MoreConnectorPainter extends CustomPainter {
  const _MoreConnectorPainter({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.06, 0)
      ..cubicTo(
        size.width * 0.20,
        0,
        size.width * 0.34,
        10,
        size.width * 0.42,
        24,
      )
      ..cubicTo(
        size.width * 0.46,
        38,
        size.width * 0.485,
        size.height - 8,
        size.width * 0.495,
        size.height - 2,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 2,
        size.width * 0.505,
        size.height - 2,
      )
      ..cubicTo(
        size.width * 0.515,
        size.height - 8,
        size.width * 0.54,
        38,
        size.width * 0.58,
        24,
      )
      ..cubicTo(
        size.width * 0.66,
        10,
        size.width * 0.80,
        0,
        size.width * 0.94,
        0,
      )
      ..lineTo(size.width * 0.06, 0)
      ..close();

    final fillPaint = Paint()..color = color;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _MoreConnectorPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderColor != borderColor;
  }
}
