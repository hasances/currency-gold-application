import 'package:flutter/material.dart';
import 'currency_tab.dart';
import 'gold_tab.dart';
//import 'chart_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 🔥 WICHTIG
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money Exchanger'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Currency'),
              Tab(text: 'Gold'),
              //Tab(text: 'Chart'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrencyTab(),
            GoldTab(),
            //ChartTab(),
          ],
        ),
      ),
    );
  }
}
