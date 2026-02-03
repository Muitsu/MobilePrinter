import 'package:flutter/material.dart';

class RadarAnimation extends StatefulWidget {
  const RadarAnimation({super.key});

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 1; i <= 3; i++)
              Opacity(
                opacity: (1.0 - _radarController.value).clamp(0, 1),
                child: Transform.scale(
                  scale: 0.5 + (_radarController.value * i * 0.5),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00B4D8).withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF00B4D8),
              child: Icon(Icons.print, color: Colors.white, size: 35),
            ),
          ],
        );
      },
    );
  }
}
