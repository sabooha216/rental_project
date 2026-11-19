import 'package:flutter/material.dart';

/// Ijari logo drawn in code (same artwork as the launcher icon).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.rounded = true});

  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _LogoPainter(rounded: rounded)),
      );
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.rounded});

  final bool rounded;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final rect = Offset.zero & size;

    // background
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF26A69A), Color(0xFF00695C)],
      ).createShader(rect);
    if (rounded) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(22 * s)), bg);
    } else {
      canvas.drawRect(rect, bg);
    }

    // house (filled + rounded joins)
    final house = Path()
      ..moveTo(50 * s, 20 * s)
      ..lineTo(82 * s, 46 * s)
      ..lineTo(82 * s, 80 * s)
      ..lineTo(18 * s, 80 * s)
      ..lineTo(18 * s, 46 * s)
      ..close();
    canvas.drawPath(house, Paint()..color = Colors.white);
    canvas.drawPath(
      house,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * s
        ..strokeJoin = StrokeJoin.round,
    );

    // keyhole
    final amber = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(Offset(50 * s, 56 * s), 7 * s, amber);
    canvas.drawPath(
      Path()
        ..moveTo(46.5 * s, 60 * s)
        ..lineTo(53.5 * s, 60 * s)
        ..lineTo(56 * s, 74 * s)
        ..lineTo(44 * s, 74 * s)
        ..close(),
      amber,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.rounded != rounded;
}
