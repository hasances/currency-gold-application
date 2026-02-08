const http = require('http');

console.log('🧪 Testing Currency & Gold Server...\n');

const BASE_URL = 'http://localhost:3000';

function testEndpoint(path, name) {
  return new Promise((resolve) => {
    console.log(`Testing ${name}...`);
    const startTime = Date.now();
    
    http.get(`${BASE_URL}${path}`, (res) => {
      const duration = Date.now() - startTime;
      let data = '';
      
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`  ✅ ${name}: OK (${duration}ms)`);
          console.log(`     Status: ${res.statusCode}`);
          console.log(`     Data: ${data.substring(0, 80)}...\n`);
        } else {
          console.log(`  ❌ ${name}: Failed`);
          console.log(`     Status: ${res.statusCode}`);
          console.log(`     Response: ${data}\n`);
        }
        resolve();
      });
    }).on('error', (err) => {
      console.log(`  ❌ ${name}: Connection Error`);
      console.log(`     Error: ${err.message}\n`);
      resolve();
    });
  });
}

async function runTests() {
  await testEndpoint('/health', 'Health Check');
  await testEndpoint('/rates', 'Currency Rates');
  await testEndpoint('/gold', 'Gold Prices');
  await testEndpoint('/gold/history?days=7', 'Gold History (7 days)');
  
  console.log('═══════════════════════════════════');
  console.log('Tests abgeschlossen!');
  console.log('\nFalls ein Test fehlschlägt:');
  console.log('1. Ist der Server gestartet? (npm start)');
  console.log('2. Läuft er auf Port 3000?');
  console.log('3. Wurde der Server neu gestartet nach Code-Änderungen?');
}

runTests();
