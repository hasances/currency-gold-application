import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class GoldItem {
  String coinName;
  int quantity;

  GoldItem({required this.coinName, required this.quantity});

  Map<String, dynamic> toJson() => {'coinName': coinName, 'quantity': quantity};

  factory GoldItem.fromJson(Map<String, dynamic> json) =>
      GoldItem(coinName: json['coinName'], quantity: json['quantity']);
}

class GoldTab extends StatefulWidget {
  const GoldTab({super.key});

  @override
  State<GoldTab> createState() => _GoldTabState();
}

class _GoldTabState extends State<GoldTab> {
  Map<String, dynamic> coins = {};
  String selectedCoin = '';
  String selectedCurrency = 'USD';
  final currencies = ['USD', 'EUR', 'TRY'];
  bool loading = true;

  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );

  List<GoldItem> cart = [];

  // Undo Snapshot (kompletter Zustand)
  List<GoldItem> undoSnapshot = [];

  @override
  void initState() {
    super.initState();
    fetchGold();
    loadCart();
  }

  /* ------------------ API ------------------ */

  Future<void> fetchGold() async {
    try {
      final res = await http.get(Uri.parse(Config.goldEndpoint));
      final data = jsonDecode(res.body);
      setState(() {
        coins = Map<String, dynamic>.from(data['coins']);
        selectedCoin = coins.keys.first;
        loading = false;
      });
    } catch (e) {
      debugPrint('Gold Fetch Fehler: $e');
    }
  }

  /* ------------------ Persistenz ------------------ */

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cart.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('gold_cart', jsonList);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('gold_cart');
    if (jsonList != null) {
      setState(() {
        cart = jsonList.map((e) => GoldItem.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  /* ------------------ Logik ------------------ */

  void addToCart() {
    final qty = int.tryParse(quantityController.text) ?? 1;

    setState(() {
      final existing = cart.where((e) => e.coinName == selectedCoin).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity += qty;
      } else {
        cart.add(GoldItem(coinName: selectedCoin, quantity: qty));
      }
    });

    saveCart();
    quantityController.text = '1';
  }

  void removeItem(int index) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    setState(() {
      undoSnapshot = List.from(
        cart.map((e) => GoldItem(coinName: e.coinName, quantity: e.quantity)),
      );
      cart.removeAt(index);
    });

    saveCart();
    showUndoSnackBar('Eintrag entfernt');
  }

  void clearCart() {
    if (cart.isEmpty) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    setState(() {
      undoSnapshot = List.from(
        cart.map((e) => GoldItem(coinName: e.coinName, quantity: e.quantity)),
      );
      cart.clear();
    });

    saveCart();
    showUndoSnackBar('Alle Einträge entfernt');
  }

  void undo() {
    if (undoSnapshot.isEmpty) return;

    setState(() {
      cart = undoSnapshot
          .map((e) => GoldItem(coinName: e.coinName, quantity: e.quantity))
          .toList();
      undoSnapshot = [];
    });

    saveCart();
  }

  void showUndoSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'Rückgängig', onPressed: undo),
      ),
    );
  }

  /* ------------------ UI ------------------ */

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    double totalSpot = 0;
    double totalDealer = 0;

    for (var item in cart) {
      final coinData = coins[item.coinName];
      final weight = coinData?['weight'] ?? 1.0;
      final data = coinData?[selectedCurrency] ?? {};
      final spot = data['spot'] ?? 0.0;

      final grams = item.quantity * weight;
      final spotTotal = (spot / weight) * grams;
      totalSpot += spotTotal;
      totalDealer += spotTotal * 1.04;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedCoin,
            decoration: const InputDecoration(
              labelText: 'Münze',
              border: OutlineInputBorder(),
            ),
            items: coins.keys.map((coin) {
              final w = coins[coin]['weight'];
              final k = coins[coin]['karat'];
              return DropdownMenuItem(
                value: coin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(coin),
                    Text(
                      '${w.toStringAsFixed(2)}g • $k K',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedCoin = v!),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Währung',
              border: OutlineInputBorder(),
            ),
            items: currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => selectedCurrency = v!),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Anzahl',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: addToCart,
                child: const Text('Hinzufügen'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: clearCart,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                final coinData = coins[item.coinName];
                final weight = coinData?['weight'] ?? 1.0;
                final data = coinData?[selectedCurrency] ?? {};
                final spot = data['spot'] ?? 0.0;

                final grams = item.quantity * weight;
                final spotTotal = (spot / weight) * grams;
                final dealerTotal = spotTotal * 1.04;

                return Dismissible(
                  key: ValueKey(item.coinName),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => removeItem(index),
                  child: Card(
                    child: ListTile(
                      title: Text(item.coinName),
                      subtitle: Text('Anzahl: ${item.quantity}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Spot: ${spotTotal.toStringAsFixed(2)} $selectedCurrency',
                          ),
                          Text(
                            'Händler: ${dealerTotal.toStringAsFixed(2)} $selectedCurrency',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Text(
            'Gesamt Spot: ${totalSpot.toStringAsFixed(2)} $selectedCurrency',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Gesamt Händler: ${totalDealer.toStringAsFixed(2)} $selectedCurrency',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
