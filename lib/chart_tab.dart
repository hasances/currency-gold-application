import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:currency_gold_application/chart_point.dart';
import 'package:currency_gold_application/price_chart.dart';
import 'package:currency_gold_application/config.dart';

class ChartTab extends StatefulWidget {
  const ChartTab({super.key});

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  String selectedRange = '7T';

  final Map<String, int> ranges = {'7T': 7, '1M': 30, '1J': 365};

  List<ChartPoint> chartData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory(ranges[selectedRange]!);
  }

  Future<void> fetchHistory(int days) async {
    setState(() => loading = true);

    final response = await http.get(
      Uri.parse(Config.goldHistoryEndpoint(days)),
    );

    final List data = jsonDecode(response.body);

    setState(() {
      chartData = data.map((e) {
        return ChartPoint(
          date: DateTime.parse(e['date']),
          value: (e['priceUSD'] as num).toDouble(),
        );
      }).toList();
      loading = false;
    });
  }

  List<ChartPoint> mockData(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      return ChartPoint(
        date: now.subtract(Duration(days: days - i)),
        value: 60 + i * 0.15,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //final data = mockData(ranges[selectedRange]!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: ranges.keys.map((key) {
              return ChoiceChip(
                label: Text(key),
                selected: selectedRange == key,
                onSelected: (_) {
                  setState(() => selectedRange = key);
                  fetchHistory(ranges[key]!);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : PriceChart(data: chartData, currency: 'EUR'),
          ),
        ],
      ),
    );
  }
}
