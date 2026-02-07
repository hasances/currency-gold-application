import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class CurrencyTab extends StatefulWidget {
  const CurrencyTab({super.key});

  @override
  State<CurrencyTab> createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  Map<String, double> rates = {};
  Map<String, double> previousRates = {};
  String base = 'EUR';
  bool loading = true;
  Timer? updateTimer;

  final List<String> baseFavorites = ['EUR', 'TRY', 'USD', 'GBP', 'CHF'];
  final TextEditingController amountController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    loadRates();
    updateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchRates(),
    );
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  Future<void> loadRates() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRates = prefs.getString('rates');
    if (storedRates != null) {
      final decoded = jsonDecode(storedRates) as Map<String, dynamic>;
      setState(() {
        rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
        // EUR manuell hinzufügen, falls nicht vorhanden
        if (!rates.containsKey('EUR')) rates['EUR'] = 1.0;

        loading = false;
        if (!rates.containsKey(base) && rates.isNotEmpty)
          base = rates.keys.first;
      });
    }
    fetchRates();
  }

  Future<void> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(Config.ratesEndpoint));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawRates = Map<String, dynamic>.from(data['rates']);
        setState(() {
          previousRates = Map.from(rates);
          rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));

          // EUR immer hinzufügen
          rates['EUR'] = 1.0;

          base = rates.containsKey(base)
              ? base
              : (rates.keys.isNotEmpty ? rates.keys.first : 'EUR');
          loading = false;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rates', jsonEncode(rates));
      }
    } catch (e) {
      debugPrint('Currency Fetch Fehler: $e');
      setState(() => loading = false);
    }
  }

  Widget rateRow(String currency) {
    final rate = currency == base ? 1.0 : (rates[currency] ?? 0.0);
    final prev = currency == base ? 1.0 : (previousRates[currency] ?? rate);
    final trend = rate > prev
        ? '↑'
        : rate < prev
        ? '↓'
        : '';
    final trendColor = trend == '↑'
        ? Colors.green
        : trend == '↓'
        ? Colors.red
        : Colors.grey;

    final inputAmount = double.tryParse(amountController.text) ?? 1.0;
    final converted = currency == base
        ? inputAmount
        : inputAmount * (rate / (rates[base] ?? 1.0));

    return ListTile(
      title: Text(currency),
      subtitle: Text('$base → $currency'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(converted.toStringAsFixed(2)),
              Text(trend, style: TextStyle(color: trendColor)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: converted.toStringAsFixed(2)),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$currency Betrag kopiert')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (rates.isEmpty)
      return const Center(child: Text("Keine Währungen verfügbar"));

    // Favoriten: Basis zuerst, dann restliche Favoriten, dann andere
    final List<String> displayFavorites = [];

    // Basis immer zuerst
    displayFavorites.add(base);

    // Restliche Favoriten (nur wenn vorhanden in rates)
    for (var f in baseFavorites) {
      if (f != base && rates.containsKey(f)) displayFavorites.add(f);
    }

    // Restliche Währungen alphabetisch
    final otherRates =
        rates.keys.where((c) => !displayFavorites.contains(c)).toList()..sort();

    // Alle Items für Dropdown
    final allItems = [...displayFavorites, ...otherRates];

    // Sicherstellen, dass Dropdown value in Items enthalten ist
    final dropdownValue = allItems.contains(base) ? base : allItems.first;

    return RefreshIndicator(
      onRefresh: fetchRates,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dropdown Basiswährung
          Row(
            children: [
              const Text('Basiswährung: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: dropdownValue,
                items: allItems
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => base = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Betrag-Eingabe
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Betrag in $base',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Favoriten anzeigen
          ...displayFavorites.map((c) => rateRow(c)),
          if (displayFavorites.isNotEmpty) const Divider(height: 24),

          // Restliche Währungen
          ...otherRates.map((c) => rateRow(c)),
        ],
      ),
    );
  }
}
