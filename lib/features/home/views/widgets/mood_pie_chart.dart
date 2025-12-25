import 'dart:math';
import 'package:flutter/material.dart';

class MoodPieChart extends StatelessWidget {
  final Map<String, int> data;
  final Function(String) getColor;
  final Color holeColor; // NEW: Pass the background color here

  const MoodPieChart({
    super.key,
    required this.data,
    required this.getColor,
    required this.holeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
          height: 200,
          child: Center(
              child: Text("No data to show",
                  style: TextStyle(color: Colors.grey))));
    }

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // THE CHART
          Expanded(
            flex: 3,
            child: CustomPaint(
              // Pass the holeColor to the painter
              painter: _PieChartPainter(data, getColor, holeColor),
              child: Container(),
            ),
          ),
          // THE LEGEND
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.keys.map((key) {
                final color = Color(getColor(key));
                final count = data[key]!;
                final total = data.values.reduce((a, b) => a + b);
                final percentage = ((count / total) * 100).toStringAsFixed(0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text("$percentage% $key",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Function(String) getColor;
  final Color holeColor;

  _PieChartPainter(this.data, this.getColor, this.holeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) * 0.8;
    final total = data.values.fold(0, (sum, item) => sum + item);

    double startAngle = -pi / 2;

    data.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi;
      final paint = Paint()
        ..color = Color(getColor(key))
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // White border between slices
      final borderPaint = Paint()
        ..color = holeColor // Use hole color for borders to blend in
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    });

    // Draw Inner Circle (The "Donut" Hole) - Now Solid!
    final centerCirclePaint = Paint()..color = holeColor;
    canvas.drawCircle(center, radius * 0.6, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
