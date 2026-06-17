import 'package:flutter/material.dart';

class MobileGameLayout extends StatelessWidget {
  const MobileGameLayout({
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
    return Column(
      children: [
        prompt,
        const SizedBox(height: 10),
        hud,
        const SizedBox(height: 10),
        Expanded(child: globe),
        const SizedBox(height: 10),
        results,
      ],
    );
  }
}
