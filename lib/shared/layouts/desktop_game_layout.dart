import 'package:flutter/material.dart';

class DesktopGameLayout extends StatelessWidget {
  const DesktopGameLayout({
    super.key,
    required this.globe,
    required this.sidePanel,
  });

  final Widget globe;
  final Widget sidePanel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: globe),
        const SizedBox(width: 24),
        SizedBox(
          width: 360,
          child: Center(child: sidePanel),
        ),
      ],
    );
  }
}
