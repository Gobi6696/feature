/**
 * TN Dam Level Scraper
 * Source: https://tnagriculture.in/ARS/home/reservoir
 * Official Tamil Nadu Agriculture Department - Daily Storage & Flow Bulletin
 *
 * HTML Table columns (index):
 *  0 - Reservoir name
 *  1 - Full Depth (Feet)   = maxHeight
 *  2 - Full Capacity (MCft) = maxCapacity (÷1000 → TMC)
 *  3 - Current Year Level (Feet) = currentHeight
 *  4 - Current Year Storage (MCft) = currentStorage (÷1000 → TMC)
 *  5 - Current Year Inflow (CuSecs) = inflow
 *  6 - Current Year Outflow (CuSecs) = outflow
 *  7 - Last Year Level (Feet) = lastYearLevel
 *  8 - Last Year Storage (MCft) = lastYearStorage
 */

const axios = require('axios');
const cheerio = require('cheerio');

// ─── Mapping: site name → internal dam ID used in the Flutter app ────────────
const DAM_NAME_MAP = {
  'METTUR':        { id: 'mettur',         district: 'Salem',          river: 'Cauvery',       lat: 11.7997, lng: 77.8016 },
  'BHAVANISAGAR':  { id: 'bhavanisagar',   district: 'Erode',          river: 'Bhavani',       lat: 11.4674, lng: 77.1264 },
  'VAIGAI':        { id: 'vaigai',         district: 'Theni',          river: 'Vaigai',        lat: 10.0543, lng: 77.5855 },
  'ALIYAR':        { id: 'aliyar',         district: 'Coimbatore',     river: 'Aliyar',        lat: 10.5074, lng: 76.9384 },
  'SHOLAYAR':      { id: 'sholayar',       district: 'Coimbatore',     river: 'Sholayar',      lat: 10.4000, lng: 76.9000 },
  'PAPANASAM':     { id: 'papanasam',      district: 'Tenkasi',        river: 'Thamirabarani', lat:  8.9333, lng: 77.3167 },
  'MANIMUTHAR':    { id: 'manimuthar',     district: 'Tirunelveli',    river: 'Manimuthar',    lat:  8.8667, lng: 77.3333 },
  'SATHANUR':      { id: 'sathanur',       district: 'Tiruvannamalai', river: 'Thenpennai',    lat: 12.0167, lng: 79.0833 },
  'KRISHNAGIRI':   { id: 'krishnagiri',    district: 'Krishnagiri',    river: 'Palarmagalar',  lat: 12.4844, lng: 78.2135 },
  'AMARAVATHI':    { id: 'amaravathi',     district: 'Tiruppur',       river: 'Amaravathi',    lat: 10.3928, lng: 77.2240 },
  'PECHIPARAI':    { id: 'pechiparai',     district: 'Kanyakumari',    river: 'Kodayar',       lat:  8.2000, lng: 77.3000 },
  'PERUNCHANI':    { id: 'perunchani',     district: 'Kanyakumari',    river: 'Paralayar',     lat:  8.3500, lng: 77.2500 },
  'THIRUMURTHY':   { id: 'thirumoorthy',   district: 'Tiruppur',       river: 'Amaravathi',    lat: 10.5700, lng: 77.1200 },
  'PARAMBIKULAM':  { id: 'aliyar',         district: 'Coimbatore',     river: 'Aliyar',        lat: 10.3600, lng: 76.7800 },
};

// Aliases for partial name matches
const NAME_ALIASES = [
  { match: 'METTUR',       id: 'METTUR' },
  { match: 'BHAVANI',      id: 'BHAVANISAGAR' },
  { match: 'VAIGAI',       id: 'VAIGAI' },
  { match: 'ALIYAR',       id: 'ALIYAR' },
  { match: 'SHOLAYAR',     id: 'SHOLAYAR' },
  { match: 'PAPANASAM',    id: 'PAPANASAM' },
  { match: 'MANIMUTHAR',   id: 'MANIMUTHAR' },
  { match: 'SATHANUR',     id: 'SATHANUR' },
  { match: 'KRISHNAGIRI',  id: 'KRISHNAGIRI' },
  { match: 'AMARAVATHI',   id: 'AMARAVATHI' },
  { match: 'PECHIPARAI',   id: 'PECHIPARAI' },
  { match: 'PERUNCHANI',   id: 'PERUNCHANI' },
  { match: 'THIRUMURTH',   id: 'THIRUMURTHY' },
  { match: 'PARAMBIKULAM', id: 'PARAMBIKULAM' },
];

/** Resolve a raw site name to our map key */
function resolveName(raw) {
  const upper = raw.toUpperCase().trim().replace(/[^A-Z]/g, '');
  for (const alias of NAME_ALIASES) {
    if (upper.includes(alias.match)) return alias.id;
  }
  return null;
}

/** Determine alert level from storage percentage */
function alertLevel(pct) {
  if (pct >= 90) return 'Danger';
  if (pct >= 75) return 'Warning';
  if (pct >= 50) return 'Watch';
  return 'Normal';
}

/** Parse a numeric cell text, return 0 on failure */
function num(text) {
  const v = parseFloat((text || '').trim());
  return isNaN(v) ? 0 : v;
}

/** Main scrape function — returns array of dam objects */
async function scrapeDams(dateStr = null) {
  const url = dateStr
    ? `https://tnagriculture.in/ARS/home/reservoir/${dateStr}`
    : 'https://tnagriculture.in/ARS/home/reservoir';

  console.log(`[Scraper] Fetching: ${url}`);

  const response = await axios.get(url, {
    timeout: 15000,
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
    },
  });

  const $ = cheerio.load(response.data);

  // Extract the bulletin date shown on page
  let bulletinDate = new Date().toISOString().slice(0, 10);
  const dateText = $('.alert-danger').text().trim();
  if (dateText) {
    // format is "DATE :- DD-MM-YYYY"
    const m = dateText.match(/(\d{2})-(\d{2})-(\d{4})/);
    if (m) bulletinDate = `${m[3]}-${m[2]}-${m[1]}`;
  }

  const dams = [];

  // Iterate each data row in the table body
  $('table tbody tr').each((_, row) => {
    const cells = $(row).find('td');
    if (cells.length < 7) return; // skip empty/header rows

    const rawName  = $(cells[0]).text().trim();
    const mapKey   = resolveName(rawName);
    if (!mapKey) return; // not a TN dam we track

    const info = DAM_NAME_MAP[mapKey];
    if (!info) return;

    const maxHeightFt     = num($(cells[1]).text());
    const maxCapMCft      = num($(cells[2]).text());
    const currentLevelFt  = num($(cells[3]).text());
    const currentStorMCft = num($(cells[4]).text());
    const inflowCusecs    = num($(cells[5]).text());
    const outflowCusecs   = num($(cells[6]).text());

    // Convert MCft → TMC (1 TMC = 1000 MCft)
    const maxCapTMC     = parseFloat((maxCapMCft / 1000).toFixed(3));
    const currentStorTMC = parseFloat((currentStorMCft / 1000).toFixed(3));

    // Percentage relative to full capacity
    const storagePct = maxCapMCft > 0
      ? parseFloat(((currentStorMCft / maxCapMCft) * 100).toFixed(1))
      : 0;

    const alert = alertLevel(storagePct);

    dams.push({
      id:                info.id,
      name:              rawName.replace(/\*+/g, '').replace(/\s+/g, ' ').trim(),
      district:          info.district,
      river:             info.river,
      latitude:          info.lat,
      longitude:         info.lng,
      maxHeight:         maxHeightFt,
      maxCapacity:       maxCapTMC,
      currentHeight:     currentLevelFt,
      currentStorage:    currentStorTMC,
      storagePercentage: storagePct,
      inflow:            inflowCusecs,
      outflow:           outflowCusecs,
      alertLevel:        alert,
      dataSource:        'tnagriculture.in',
      bulletinDate:      bulletinDate,
      scrapedAt:         new Date().toISOString(),
    });
  });

  console.log(`[Scraper] Scraped ${dams.length} dams for date ${bulletinDate}`);
  return { dams, bulletinDate };
}

module.exports = { scrapeDams };
