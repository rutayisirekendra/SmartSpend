import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class SpendingPieChart extends StatefulWidget {
  const SpendingPieChart({Key? key}) : super(key: key);

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int touchedIndex = -1;

  // Mock data for now
  final Map<String, double> dataMap = {
    "Food": 500.45,
    "Transport": 150.20,
    "Entertainment": 200.00,
    "Bills": 300.80,
    "Other": 80.50,
  };

  final List<Color> colorList = [
    AppTheme.accentOrange,
    Colors.blueAccent,
    Colors.green,
    Colors.purple,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Spending Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 250),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(dataMap.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 22.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final String key = dataMap.keys.elementAt(i);
      final double value = dataMap.values.elementAt(i);

      return PieChartSectionData(
        color: colorList[i % colorList.length],
        value: value,
        title: '\$${value.toStringAsFixed(0)}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
        ),
      );
    });
  }
}
