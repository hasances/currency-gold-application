const express = require('express');
const fetch = require('node-fetch'); // node-fetch v2
const cors = require('cors');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = express();
app.use(cors());

// ==================== KONFIGURATION ====================
const GOLD_API_KEY = process.env.GOLD_API_KEY;
const PORT = process.env.PORT || 3000;
const CACHE_DURATION_MS = 5 * 60 * 1000; // 5 Minuten Cache
const GOLD_CACHE_DURATION_MS = 10 * 60 * 1000; // 10 Minuten für Gold
const HISTORY_FILE = path.join(__dirname, 'gold_history.json');
const PREMIUM_PERCENT = 4;

// ==================== IN-MEMORY CACHE ====================
const cache = {
  rates: { data: null, timestamp: 0 },
  gold: { data: null, timestamp: 0 }
};

function isCacheValid(cacheEntry, maxAge) {
  return cacheEntry.data && (Date.now() - cacheEntry.timestamp) < maxAge;
}

function setCache(key, data) {
  cache[key] = { data, timestamp: Date.now() };
}

// ==================== RATE LIMITING ====================
const requestCounts = new Map();
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 Minute
const MAX_REQUESTS_PER_WINDOW = 30;

function rateLimitMiddleware(req, res, next) {
  const ip = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  
  if (!requestCounts.has(ip)) {
    requestCounts.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
  } else {
    const record = requestCounts.get(ip);
    if (now > record.resetTime) {
      record.count = 1;
      record.resetTime = now + RATE_LIMIT_WINDOW;
    } else {
      record.count++;
      if (record.count > MAX_REQUESTS_PER_WINDOW) {
        return res.status(429).json({ 
          error: 'Too many requests', 
          retryAfter: Math.ceil((record.resetTime - now) / 1000) 
        });
      }
    }
  }
  next();
}

app.use(rateLimitMiddleware);

// ==================== HISTORY MANAGEMENT ====================
function loadHistory() {
  if (!fs.existsSync(HISTORY_FILE)) return [];
  try {
    return JSON.parse(fs.readFileSync(HISTORY_FILE));
  } catch (err) {
    console.error('History Load Fehler:', err);
    return [];
  }
}

function saveHistory(data) {
  try {
    fs.writeFileSync(HISTORY_FILE, JSON.stringify(data, null, 2));
  } catch (err) {
    console.error('History Save Fehler:', err);
  }
}

async function storeTodayGoldPrice(pricePerGramUSD) {
  const history = loadHistory();
  const today = new Date().toISOString().split('T')[0];

  const exists = history.find(h => h.date === today);
  if (exists) return;

  history.push({
    date: today,
    priceUSD: Number(pricePerGramUSD.toFixed(2)),
  });

  saveHistory(history);
  console.log('Goldpreis gespeichert:', today);
}

// ==================== ENDPOINTS ====================

// Health Check für Deployment
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Chart - Historische Daten
app.get('/gold/history', (req, res) => {
  const days = Number(req.query.days ?? 30);
  const history = loadHistory();

  const sliced = history.slice(-days);
  res.json(sliced);
});

// WÄHRUNGEN mit Caching
app.get('/rates', async (req, res) => {
  // Prüfe Cache zuerst
  if (isCacheValid(cache.rates, CACHE_DURATION_MS)) {
    console.log('Serving rates from cache');
    return res.json(cache.rates.data);
  }

  try {
    console.log('Fetching fresh rates data...');
    const response = await fetch('https://api.frankfurter.app/latest');
    const data = await response.json();
    
    setCache('rates', data);
    res.json(data);
  } catch (err) {
    console.error('Currency Fetch Fehler:', err);
    
    // Fallback auf alten Cache oder Standardwerte
    if (cache.rates.data) {
      console.log('Using stale cache as fallback');
      return res.json(cache.rates.data);
    }
    
    res.json({
      base: 'EUR',
      rates: { USD: 1.1, GBP: 0.85, TRY: 32.0, EUR: 1.0 },
    });
  }
});

// GOLD Preise mit Caching
app.get('/gold', async (req, res) => {
  console.log('Gold Request empfangen...');

  // Münzen-Definitionen
  const coins = {
    'Gramm': { weight: 1, karat: 24 },
    'Kilogramm': { weight: 1000, karat: 24 },
    'Krügerrand (1 oz)': { weight: 31.1035, karat: 24 },
    'Maple Leaf (1 oz)': { weight: 31.1035, karat: 24 },
    'Philharmoniker (1 oz)': { weight: 31.1035, karat: 24 },
    'Cumhuriyet Altını': { weight: 7.21, karat: 22 },
    'Ata Altını': { weight: 7.21, karat: 22 },
    'Çeyrek Altın': { weight: 1.75, karat: 22 },
    'Yarim Altın': { weight: 3.5, karat: 22 },
    'Tam Altın (Ziynet)': { weight: 7.01, karat: 22 },
    'Reşat Altını': { weight: 7.21, karat: 22 },
    'Gremse Altını': { weight: 17.5, karat: 22 },
    '22 Ayar Bilezik': { weight: 1, karat: 22 },
  };

  // Prüfe Cache zuerst
  if (isCacheValid(cache.gold, GOLD_CACHE_DURATION_MS)) {
    console.log('Serving gold data from cache');
    return res.json(cache.gold.data);
  }

  try {
    if (!GOLD_API_KEY) {
      throw new Error('Kein GoldAPI-Key gesetzt. Bitte GOLD_API_KEY in .env setzen.');
    }

    console.log('Fetching fresh gold data...');
    
    // Goldpreis USD pro Unze
    const goldResponse = await fetch('https://www.goldapi.io/api/XAU/USD', {
      headers: { 'x-access-token': GOLD_API_KEY },
    });
    
    if (!goldResponse.ok) {
      throw new Error(`GoldAPI Error: ${goldResponse.status} ${goldResponse.statusText}`);
    }
    
    const goldData = await goldResponse.json();
    console.log('GoldAPI Response:', goldData);

    if (!goldData.price) throw new Error('Kein Preis von GoldAPI');

    const pricePerOzUSD = goldData.price;
    const pricePerGramUSD = pricePerOzUSD / 31.1035;
    await storeTodayGoldPrice(pricePerGramUSD);

    // Wechselkurse USD -> EUR, TRY
    const rateResponse = await fetch(
      'https://api.frankfurter.app/latest?from=USD&to=EUR,TRY'
    );
    const rateData = await rateResponse.json();

    const rates = {
      USD: 1,
      EUR: rateData.rates.EUR || 0.93,
      TRY: rateData.rates.TRY || 32.0,
    };

    // Berechnung pro Münze
    const result = {};
    for (const [coin, data] of Object.entries(coins)) {
      const purity = data.karat / 24;
      const spotUSD = data.weight * purity * pricePerGramUSD;

      const coinEntry = { weight: data.weight, karat: data.karat };

      for (const [cur, rate] of Object.entries(rates)) {
        const spot = spotUSD * rate;
        const dealer = spot * (1 + PREMIUM_PERCENT / 100);
        coinEntry[cur] = {
          spot: parseFloat(spot.toFixed(2)),
          dealer: parseFloat(dealer.toFixed(2)),
        };
      }

      result[coin] = coinEntry;
    }

    const responseData = { 
      coins: result,
      cached: false,
      timestamp: new Date().toISOString()
    };
    
    setCache('gold', responseData);
    res.json(responseData);
    
  } catch (err) {
    console.error('Gold Fetch Fehler:', err.message);

    // Fallback auf alten Cache
    if (cache.gold.data) {
      console.log('Using stale gold cache as fallback');
      const staleData = { ...cache.gold.data, stale: true };
      return res.json(staleData);
    }

    // Fallback-Testwerte als letzte Option
    console.log('Using fallback test values');
    const testRates = { USD: 1, EUR: 0.93, TRY: 32 };
    const testPricePerGramUSD = 59;

    const fallbackResult = {};
    for (const [coin, data] of Object.entries(coins)) {
      const purity = data.karat / 24;
      const spotUSD = data.weight * purity * testPricePerGramUSD;

      const coinEntry = { weight: data.weight, karat: data.karat };
      for (const [cur, rate] of Object.entries(testRates)) {
        const spot = spotUSD * rate;
        const dealer = spot * 1.04;
        coinEntry[cur] = {
          spot: parseFloat(spot.toFixed(2)),
          dealer: parseFloat(dealer.toFixed(2)),
        };
      }

      fallbackResult[coin] = coinEntry;
    }

    res.json({ 
      coins: fallbackResult,
      fallback: true,
      timestamp: new Date().toISOString()
    });
  }
});

// ==================== SERVER START ====================
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════╗
║   Currency & Gold Server                      ║
║   Running on: http://localhost:${PORT}        ║
║   Cache Duration: ${CACHE_DURATION_MS/1000}s (rates), ${GOLD_CACHE_DURATION_MS/1000}s (gold)  ║
║   Rate Limit: ${MAX_REQUESTS_PER_WINDOW} req/min              ║
╚═══════════════════════════════════════════════╝
  `);
});
