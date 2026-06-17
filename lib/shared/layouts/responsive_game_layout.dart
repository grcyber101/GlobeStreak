import 'package:flutter/material.dart';

import '../../core/constants/app_breakpoints.dart';
import 'desktop_game_layout.dart';
import 'mobile_game_layout.dart';

class ResponsiveGameLayout extends StatelessWidget {
  const ResponsiveGameLayout({
    super.key,
    required this.prompt,
    required this.hud,
    required this.globe,
    required this.results,
  });

  final Widget prompt;
  final Widget hud;
  final Widget globe;
  final Widget results;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= AppBreakpoints.desktopMinWidth;
        final horizontalPadding = isDesktop ? 24.0 : 14.0;
        final maxContentWidth = isDesktop
            ? AppBreakpoints.maxDesktopContentWidth
            : AppBreakpoints.maxMobileContentWidth;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: isDesktop
                    ? DesktopGameLayout(
                        globe: globe,
                        sidePanel: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hud,
                            const SizedBox(height: 14),
                            prompt,
                            const SizedBox(height: 14),
                            results,
                          ],
                        ),
                      )
                    : MobileGameLayout(
                        prompt: prompt,
                        hud: hud,
                        globe: globe,
                        results: results,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
