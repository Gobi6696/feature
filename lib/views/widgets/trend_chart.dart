import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../models/dam_model.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';

class TrendChart extends StatelessWidget {
  final List<HistoricalDataPoint> history;
  final bool showStorage; // true: storage (TMC), false: height (ft)
  final Color lineColor;

  const TrendChart({
    super.key,
    required this.history,
    this.showStorage = true,
    this.lineColor = const Color(0xFF00E5FF), // Cyan highlight
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DamProvider>();
    final lang = provider.currentLanguage;

    if (history.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(Localization.translate('no_reservoirs', lang)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showStorage
                    ? Localization.translate('trend_storage', lang)
                    : Localization.translate('trend_level', lang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Localization.translate('last_7_days', lang),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(
                history: history,
                showStorage: showStorage,
                lineColor: lineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<HistoricalDataPoint> history;
  final bool showStorage;
  final Color lineColor;

  _ChartPainter({
    required this.history,
    required this.showStorage,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paddingLeft = 40.0;
    final paddingBottom = 24.0;
    final chartWidth = width - paddingLeft;
    final chartHeight = height - paddingBottom;

    if (history.length < 2) return;

    // Get historical values based on setting
    final List<double> values = history
        .map((e) => showStorage ? e.storage : e.level)
        .toList();
    final List<DateTime> dates = history.map((e) => e.date).toList();

    // Calculate Min & Max values for scaling
    double maxValue = values.reduce((curr, next) => curr > next ? curr : next);
    double minValue = values.reduce((curr, next) => curr < next ? curr : next);

    // Padding values for chart headroom
    double range = maxValue - minValue;
    if (range == 0) {
      maxValue += 5.0;
      minValue = math.max(0.0, minValue - 5.0);
      range = maxValue - minValue;
    } else {
      maxValue += range * 0.15;
      minValue = math.max(0.0, minValue - range * 0.15);
      range = maxValue - minValue;
    }

    final double stepX = chartWidth / (values.length - 1);

    // 1. Draw Gridlines & Y-Axis Labels
    final gridLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.grey.shade400,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    const int gridSegments = 3;
    for (int i = 0; i <= gridSegments; i++) {
      final double ratio = i / gridSegments;
      final double y = chartHeight - (ratio * chartHeight);

      // Draw grid line
      canvas.drawLine(Offset(paddingLeft, y), Offset(width, y), gridLinePaint);

      // Draw Y label
      final double labelVal = minValue + (ratio * range);
      final textSpan = TextSpan(
        text: labelVal.toStringAsFixed(1),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // 2. Plot Points & Curved Path
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final double x = paddingLeft + (i * stepX);
      final double ratio = (values[i] - minValue) / range;
      final double y = chartHeight - (ratio * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      // Calculate cubic bezier control points for smooth line curves
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // 3. Draw Gradient Fill Area below curve
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.lineTo(points.first.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.25), lineColor.withOpacity(0.00)],
      ).createShader(Rect.fromLTRB(paddingLeft, 0, width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Chart Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // 5. Draw Pulse Glow / Circles on points and draw X-Axis Labels
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final ringPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final formatter = DateFormat('E'); // E.g., Mon, Tue

    for (int i = 0; i < points.length; i++) {
      // Draw point circle
      canvas.drawCircle(points[i], 3.0, pointPaint);

      // Highlight last point with a glow ring
      if (i == points.length - 1) {
        canvas.drawCircle(points[i], 6.0, ringPaint);
        canvas.drawCircle(
          points[i],
          10.0,
          ringPaint..color = lineColor.withOpacity(0.3),
        );
      }

      // Draw X-axis text label (only draw odd-indexed dates or 3/4 labels to avoid overlap)
      if (i % 2 == 0 || i == points.length - 1) {
        final labelText = formatter.format(dates[i]);
        final textSpan = TextSpan(
          text: labelText,
          style: textStyle.copyWith(color: Colors.grey.shade500),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2, chartHeight + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.showStorage != showStorage ||
        oldDelegate.lineColor != lineColor;
  }
}
