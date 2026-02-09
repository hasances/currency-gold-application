import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

// Schnelles Test-Script für Flutter
void main() async {
  print('🧪 Testing Server Connection from Flutter\n');
  
  print('Config Check:');
  print('  Development Mode: ${Config.isDevelopment}');
  print('  API Base URL: ${Config.apiBaseUrl}');
  print('  Health Endpoint: ${Config.healthEndpoint}');
  print('  Gold Endpoint: ${Config.goldEndpoint}');
  print('  Rates Endpoint: ${Config.ratesEndpoint}\n');
  
  // Test 1: Health
  print('Test 1: Health Check...');
  try {
    final healthRes = await http.get(
      Uri.parse(Config.healthEndpoint),
    ).timeout(Config.requestTimeout);
    print('  ✅ Status: ${healthRes.statusCode}');
    print('  📦 Body: ${healthRes.body}\n');
  } catch (e) {
    print('  ❌ Error: $e\n');
  }
  
  // Test 2: Rates
  print('Test 2: Currency Rates...');
  try {
    final ratesRes = await http.get(
      Uri.parse(Config.ratesEndpoint),
    ).timeout(Config.requestTimeout);
    print('  ✅ Status: ${ratesRes.statusCode}');
    print('  📦 Body: ${ratesRes.body.substring(0, 100)}...\n');
  } catch (e) {
    print('  ❌ Error: $e\n');
  }
  
  // Test 3: Gold
  print('Test 3: Gold Prices...');
  try {
    final goldRes = await http.get(
      Uri.parse(Config.goldEndpoint),
    ).timeout(Config.requestTimeout);
    print('  ✅ Status: ${goldRes.statusCode}');
    final data = jsonDecode(goldRes.body);
    print('  📦 Coins: ${data['coins']?.keys.take(3).toList()}\n');
  } catch (e) {
    print('  ❌ Error: $e\n');
  }
  
  print('═══════════════════════════════════');
  print('Tests abgeschlossen!');
}
