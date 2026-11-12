// ==============================================================================
// 📌 DOSYA: lib/core/widgets/zigzag_chart.dart
// 📌 AÇIKLAMA: Özel CustomPainter ile çizilen neon zikzaklı performans ve trend grafiği.
//              Öğrenci not gelişimini ve ödev teslim hızını görselleştirmek için kullanılır.
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// [ZigzagChartWidget], verilen [dataPoints] veri dizisini şık bir eğri/çizgi
/// ve gradyan dolgulu neon çizim olarak sunar.
class ZigzagChartWidget extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final Color glowColor;
  final double height;
  final bool showDots;
  final bool fillGradient;
  final String? title;
  final String? subtitle;

  const ZigzagChartWidget({
    super.key,
    required this.dataPoints,
    this.lineColor = AppColors.primary,
    this.glowColor = AppColors.accent,
    this.height = 85,
    this.showDots = true,
    this.fillGradient = true,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lineColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: lineColor.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: AppColors.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.onSurfaceMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: lineColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '+18% Trend',
                        style: TextStyle(
                          color: lineColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _ZigzagPainter(
                data: dataPoints,
                lineColor: lineColor,
                glowColor: glowColor,
                showDots: showDots,
                fillGradient: fillGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color glowColor;
  final bool showDots;
  final bool fillGradient;

  _ZigzagPainter({
    required this.data,
    required this.lineColor,
    required this.glowColor,
    required this.showDots,
    required this.fillGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    // Ortalama doluluk oranı hesaplama
    double sumNormalized = 0;
    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minVal) / range;
      sumNormalized += normalizedY;
      // Invert Y so highest data is at the top
      final y = size.height - 8 - (normalizedY * (size.height - 18));
      points.add(Offset(i * stepX, y));
    }
    final avgFill = sumNormalized / data.length;

    // 1. Zikzak Dolgusu: Grafik doldukça renk koyulaşır ve belirginleşir!
    if (fillGradient && points.length > 1) {
      final fillPath = Path()..moveTo(points.first.dx, size.height);
      for (final pt in points) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      // Doluluk arttıkça taban rengi daha koyu ve doygun hale gelir:
      final deepBaseColor = Color.lerp(
        lineColor,
        const Color(0xFF090E1B), // Derin koyu taban
        0.55 + (avgFill * 0.35), // Doldukça daha koyu ve belirgin!
      )!;

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.65 + (avgFill * 0.25)), // Üst kısım belirgin ve canlı
            Color.lerp(lineColor, deepBaseColor, 0.5)!.withValues(alpha: 0.75),
            deepBaseColor.withValues(alpha: 0.95), // Alt taban koyulaşmış ve oturaklı
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // 2. Neon Zikzak Çizgisi (Doluluk arttıkça daha belirgin ve kalın)
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Belirgin Neon Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35 + (avgFill * 0.2))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, glowPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // 3. Tepe & Zirve Noktaları (Glow Dots)
    if (showDots) {
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final isPeak = i > 0 && i < points.length - 1 && data[i] >= data[i - 1] && data[i] >= data[i + 1];

        // Nokta Dış Halka
        canvas.drawCircle(
          pt,
          isPeak ? 5.0 : 3.5,
          Paint()..color = glowColor.withValues(alpha: 0.5),
        );

        // Nokta İç Göbek
        canvas.drawCircle(
          pt,
          isPeak ? 2.8 : 2.0,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZigzagPainter oldDelegate) => true;
}
