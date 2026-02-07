import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_gold_application/chart_point.dart';

class PriceChart extends StatelessWidget {
  final List<ChartPoint> data;
  final String currency;

  const PriceChart({super.key, required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Keine Daten'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
