/**
 * TN Dam Tracker — Express API Server
 * Serves real scraped dam data from tnagriculture.in to the Flutter app.
 *
 * Endpoints:
 *   GET /api/dams               → today's live data
 *   GET /api/dams?date=YYYY-MM-DD → historical data for a specific date
 *   GET /api/health             → server health check
 *   GET /api/last-updated       → when data was last refreshed
 */

const express  = require('express');
const cors     = require('cors');
const cron     = require('node-cron');
const { scrapeDams } = require('./scraper');

const app  = express();
const PORT = process.env.PORT || 3001;

// ─── CORS: Allow all origins so Flutter web and emulator clients connect ──────
app.use(cors());
app.use(express.json());

// ─── In-memory cache ─────────────────────────────────────────────────────────
let cache = {
  dams:         [],
  bulletinDate: null,
  lastUpdated:  null,
  error:        null,
};

// ─── Bootstrap: scrape immediately on startup ─────────────────────────────────
async function refreshData(dateStr = null) {
  try {
    console.log('[Server] Refreshing dam data...');
    const result  = await scrapeDams(dateStr);
    cache.dams         = result.dams;
    cache.bulletinDate = result.bulletinDate;
    cache.lastUpdated  = new Date().toISOString();
    cache.error        = null;
    console.log(`[Server] ✅ Cache updated — ${cache.dams.length} dams loaded (${cache.bulletinDate})`);
  } catch (err) {
    cache.error = err.message;
    console.error('[Server] ❌ Scrape failed:', err.message);
  }
}

// Initial fetch on startup
refreshData();

// ─── Scheduled refresh every 6 hours (6am, 12pm, 6pm, midnight) ──────────────
cron.schedule('0 0,6,12,18 * * *', () => {
  console.log('[Cron] Scheduled refresh triggered');
  refreshData();
});

// ─── Routes ──────────────────────────────────────────────────────────────────

/** Health check */
app.get('/api/health', (req, res) => {
  res.json({
    status:      'ok',
    damsLoaded:  cache.dams.length,
    lastUpdated: cache.lastUpdated,
    bulletinDate: cache.bulletinDate,
    error:       cache.error,
  });
});

/** Last-updated timestamp */
app.get('/api/last-updated', (req, res) => {
  res.json({
    lastUpdated:  cache.lastUpdated,
    bulletinDate: cache.bulletinDate,
    source:       'tnagriculture.in',
  });
});

/** Main dam data endpoint */
app.get('/api/dams', async (req, res) => {
  const dateParam = req.query.date; // optional: ?date=YYYY-MM-DD

  // If a specific date is requested, scrape on-demand
  if (dateParam && /^\d{4}-\d{2}-\d{2}$/.test(dateParam)) {
    try {
      const result = await scrapeDams(dateParam);
      return res.json({
        success:      true,
        source:       'tnagriculture.in',
        bulletinDate: result.bulletinDate,
        scrapedAt:    new Date().toISOString(),
        count:        result.dams.length,
        dams:         result.dams,
      });
    } catch (err) {
      return res.status(502).json({
        success: false,
        error:   `Failed to scrape data for ${dateParam}: ${err.message}`,
      });
    }
  }

  // Return cached data for today
  if (cache.dams.length === 0) {
    // Cache is empty — try a fresh fetch
    await refreshData();
  }

  if (cache.error && cache.dams.length === 0) {
    return res.status(502).json({
      success: false,
      error:   cache.error,
      message: 'Scraper failed. Check if tnagriculture.in is reachable.',
    });
  }

  res.json({
    success:      true,
    source:       'tnagriculture.in',
    bulletinDate: cache.bulletinDate,
    lastUpdated:  cache.lastUpdated,
    count:        cache.dams.length,
    dams:         cache.dams,
  });
});

/** Force refresh (manual trigger) */
app.post('/api/refresh', async (req, res) => {
  await refreshData();
  res.json({
    success:     !cache.error,
    damsLoaded:  cache.dams.length,
    lastUpdated: cache.lastUpdated,
    error:       cache.error,
  });
});

// ─── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════════╗');
  console.log('║   🌊 TN Dam Tracker — Scraper Backend      ║');
  console.log(`║   Running at http://localhost:${PORT}          ║`);
  console.log('║   Source: tnagriculture.in/ARS/home/reservoir ║');
  console.log('╚════════════════════════════════════════════╝');
  console.log('');
});
