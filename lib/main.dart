import 'package:flutter/material.dart';
import 'currency_tab.dart';
import 'gold_tab.dart';
import 'chart_tab.dart';
import 'affiliate_tab.dart';
import 'debug_mode_check.dart';
import 'config.dart';
import 'analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Zeige Environment Info beim Start
  debugPrint('=== CURRENCY GOLD APP ===');
  debugPrint('Mode: ${Config.isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'}');
  debugPrint('API URL: ${Config.apiBaseUrl}');
  debugPrint('========================');

  // Tracke App-Start
  await AnalyticsService().incrementSessionCount();

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _analytics = AnalyticsService();
  
  // Dynamische Tab-Namen basierend auf sichtbaren Tabs
  List<String> get _tabNames {
    final showDebug = Config.isDevelopment;
    final showChartTab = false; // TODO: Aktivieren wenn Charts produktionsreif
    
    final names = ['Currency', 'Gold'];
    if (showChartTab) names.add('Chart');
    if (showDebug) names.add('Debug');
    return names;
  }

  @override
  void initState() {
    super.initState();
    
    // Anzahl Tabs hängt von Environment ab
    final showDebug = Config.isDevelopment;
    final showChartTab = false; // TODO: Aktivieren wenn Charts produktionsreif
    
    int tabCount = 2; // Currency + Gold
    if (showChartTab) tabCount++;
    if (showDebug) tabCount++;
    
    _tabController = TabController(length: tabCount, vsync: this);
    
    // Tracke initialen Tab-View
    _analytics.trackTabView(_tabNames[0]);
    
    // Listener für Tab-Wechsel
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tabName = _tabNames[_tabController.index];
        _analytics.trackTabView(tabName);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Anzahl Tabs hängt von Environment ab
    final showDebug = Config.isDevelopment;
    final showPartnerTab = false; // TODO: Aktivieren für V2 mit Affiliate
    final showChartTab = false; // TODO: Aktivieren wenn Charts produktionsreif

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Exchanger'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Currency'),
            const Tab(text: 'Gold'),
            if (showChartTab) const Tab(text: 'Chart'),
            if (showPartnerTab) const Tab(text: 'Partner'),
            if (showDebug) const Tab(text: 'Debug'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const CurrencyTab(),
          const GoldTab(),
          if (showChartTab) ChartTab(),
          if (showPartnerTab) AffiliateTab(),
          if (showDebug) const DebugModeCheck(),
        ],
      ),
    );
  }
}
