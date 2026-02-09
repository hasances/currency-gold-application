import 'package:flutter/material.dart';
import 'currency_tab.dart';
import 'gold_tab.dart';
//import 'chart_tab.dart';
import 'debug_mode_check.dart';
import 'config.dart';

void main() {
  // Zeige Environment Info beim Start
  print('=== CURRENCY GOLD APP ===');
  print('Mode: ${Config.isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'}');
  print('API URL: ${Config.apiBaseUrl}');
  print('========================');
  
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
      length: 3, // 🔥 WICHTIG: Jetzt 3 Tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money Exchanger'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Currency'),
              Tab(text: 'Gold'),
              Tab(text: 'Debug'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrencyTab(),
            GoldTab(),
            DebugModeCheck(),
          ],
        ),
      ),
    );
  }
}
