#!/usr/bin/env node

/**
 * Server Test Script
 * Prüft ob alle Endpoints funktionieren
 */

const fetch = require('node-fetch');

const BASE_URL = process.env.TEST_URL || 'http://localhost:3000';

async function testEndpoint(name, path, expectedFields = []) {
  try {
    console.log(`\n🧪 Testing ${name}...`);
    const response = await fetch(`${BASE_URL}${path}`);
    
    if (!response.ok) {
      console.log(`❌ FAILED: HTTP ${response.status}`);
      return false;
    }
    
    const data = await response.json();
    console.log(`✅ SUCCESS: HTTP ${response.status}`);
    
    // Prüfe erwartete Felder
    for (const field of expectedFields) {
      if (!data[field]) {
        console.log(`⚠️  WARNING: Missing field '${field}'`);
      }
    }
    
    // Zeige Sample-Daten
    console.log('📦 Sample:', JSON.stringify(data).substring(0, 100) + '...');
    return true;
    
  } catch (error) {
    console.log(`❌ ERROR: ${error.message}`);
    return false;
  }
}

async function runTests() {
  console.log(`
╔═══════════════════════════════════════════════╗
║   Currency & Gold Server - Test Suite        ║
║   Testing: ${BASE_URL.padEnd(35)}║
╚═══════════════════════════════════════════════╝
  `);

  const results = [];
  
  // Test 1: Health Check
  results.push(await testEndpoint('Health Check', '/health', ['status', 'timestamp']));
  
  // Test 2: Rates
  results.push(await testEndpoint('Currency Rates', '/rates', ['rates']));
  
  // Test 3: Gold
  results.push(await testEndpoint('Gold Prices', '/gold', ['coins']));
  
  // Test 4: History
  results.push(await testEndpoint('Gold History', '/gold/history?days=7', []));
  
  // Summary
  const passed = results.filter(r => r).length;
  const total = results.length;
  
  console.log(`
╔═══════════════════════════════════════════════╗
║   Results: ${passed}/${total} Tests Passed${' '.repeat(24)}║
╚═══════════════════════════════════════════════╝
  `);
  
  process.exit(passed === total ? 0 : 1);
}

runTests();
