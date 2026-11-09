import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.values,
    this.lineColor = AppColors.online,
    this.fillColor,
    this.height = 48,
    this.lineWidth = 2.0,
    this.minVal,
    this.maxVal,
  });

  final List<double> values;
  final Color lineColor;
  final Color? fillColor;
  final double height;
  final double lineWidth;
  final double? minVal;
  final double? maxVal;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('Sem histórico', style: TextStyle(color: Colors.white30, fontSize: 10)),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          values: values,
          lineColor: lineColor,
          fillColor: fillColor ?? lineColor.withValues(alpha: 0.15),
          lineWidth: lineWidth,
          minVal: minVal,
          maxVal: maxVal,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.lineWidth,
    this.minVal,
    this.maxVal,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double lineWidth;
  final double? minVal;
  final double? maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final double effectiveMin = minVal ?? values.reduce((a, b) => a < b ? a : b);
    final double effectiveMax = maxVal ?? values.reduce((a, b) => a > b ? a : b);
    final double range = (effectiveMax - effectiveMin) == 0 ? 1.0 : (effectiveMax - effectiveMin);

    final double stepX = size.width / (values.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final double normalized = (values[i] - effectiveMin) / range;
      final double x = i * stepX;
      final double y = size.height - (normalized * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == values.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Ponto final no último valor
    final double lastNorm = (values.last - effectiveMin) / range;
    final double lastX = (values.length - 1) * stepX;
    final double lastY = size.height - (lastNorm * (size.height - 8)) - 4;
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(Offset(lastX, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
