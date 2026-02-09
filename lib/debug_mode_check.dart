import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class DebugModeCheck extends StatefulWidget {
  const DebugModeCheck({super.key});

  @override
  State<DebugModeCheck> createState() => _DebugModeCheckState();
}

class _DebugModeCheckState extends State<DebugModeCheck> {
  String _testResult = '';
  bool _testing = false;

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = 'Testing...';
    });

    try {
      // Test 1: Health Endpoint
      final healthResponse = await http
          .get(Uri.parse(Config.healthEndpoint))
          .timeout(const Duration(seconds: 15));

      setState(() {
        _testResult = '✅ Health: ${healthResponse.statusCode}\n';
      });

      // Test 2: Gold Endpoint
      final goldResponse = await http
          .get(Uri.parse(Config.goldEndpoint))
          .timeout(const Duration(seconds: 15));

      final goldData = json.decode(goldResponse.body);
      
      setState(() {
        _testResult += '✅ Gold: ${goldResponse.statusCode}\n';
        _testResult += 'Coins: ${goldData['coins']?.keys.length ?? 0} types\n';
        _testResult += 'Cached: ${goldData['cached'] ?? false}\n';
      });

      // Test 3: Rates Endpoint
      final ratesResponse = await http
          .get(Uri.parse(Config.ratesEndpoint))
          .timeout(const Duration(seconds: 15));

      final ratesData = json.decode(ratesResponse.body);

      setState(() {
        _testResult += '✅ Rates: ${ratesResponse.statusCode}\n';
        _testResult += 'Currencies: ${ratesData['rates']?.keys.length ?? 0}\n';
        _testResult += '\n🎉 Alle Tests erfolgreich!';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Fehler:\n$e';
      });
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Modus: ${Config.isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Server URL:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            SelectableText(
              Config.apiBaseUrl,
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _testing ? null : _testConnection,
              child: _testing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Server Connection'),
            ),
            const SizedBox(height: 20),
            if (_testResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _testResult,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
