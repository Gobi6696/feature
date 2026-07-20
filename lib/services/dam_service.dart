import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/dam_model.dart';

/// Thrown when the Node.js scraper backend is unreachable or returns an error.
class BackendOfflineException implements Exception {
  final String message;
  const BackendOfflineException(this.message);
  @override
  String toString() => message;
}

class DamService {
  // ── Backend Scraper URL ─────────────────────────────────────────────────────
  // Production hosted Render scraper API
  static const String _productionRenderUrl =
      'https://feature-kbn0.onrender.com';

  // Android emulator needs 10.0.2.2 to reach the host machine's localhost.
  static const String _scraperBase = 'http://10.0.2.2:3001';

  // Fallback for desktop/web Flutter running on the same machine
  static const String _scraperBaseLocal = 'http://localhost:3001';

  /// Checks whether the backend is reachable and returns the base URL that works.
  /// Returns null if both URLs are unreachable.
  Future<String?> _reachableBase() async {
    for (final base in [
      _productionRenderUrl,
      _scraperBaseLocal,
      _scraperBase,
    ]) {
      try {
        final uri = Uri.parse('$base/api/health');
        final response = await http
            .get(uri)
            .timeout(
              const Duration(seconds: 25),
            ); // Render cold start can take 30-50s
        if (response.statusCode == 200) return base;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Try to fetch real data from the scraper backend.
  /// Throws [BackendOfflineException] if backend is unreachable.
  Future<List<DamModel>> _fetchFromBackend() async {
    final base = await _reachableBase();

    if (base == null) {
      throw BackendOfflineException(
        'Backend not running!\n\n'
        'Start it with:\n  cd c:\\feature\\scraper\n  npm run dev',
      );
    }

    try {
      final uri = Uri.parse('$base/api/dams');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final List<dynamic> rawDams = json['dams'];
          final bulletinDate = json['bulletinDate'] as String? ?? '';
          if (rawDams.isEmpty) {
            throw BackendOfflineException(
              'Backend returned 0 dams. Check tnagriculture.in availability.',
            );
          }
          return rawDams.map((d) => _parseDam(d, bulletinDate)).toList();
        }
      }
      throw BackendOfflineException(
        'Backend responded with status ${response.statusCode}',
      );
    } on BackendOfflineException {
      rethrow;
    } catch (e) {
      throw BackendOfflineException('Failed to fetch dam data: $e');
    }
  }

  /// Parse a single dam JSON object from the backend into a DamModel.
  DamModel _parseDam(Map<String, dynamic> d, String bulletinDate) {
    final maxHeight = (d['maxHeight'] as num).toDouble();
    final maxCapacity = (d['maxCapacity'] as num).toDouble();
    final curHeight = (d['currentHeight'] as num).toDouble();
    final curStorage = (d['currentStorage'] as num).toDouble();
    final inflow = (d['inflow'] as num).toDouble();
    final outflow = (d['outflow'] as num).toDouble();

    // Generate a realistic 7-day history anchored to today's real values
    final history = _buildHistory(
      baseLevel: curHeight,
      baseStorage: curStorage,
      baseInflow: inflow,
      baseOutflow: outflow,
      maxHeight: maxHeight,
      maxCapacity: maxCapacity,
    );

    // Determine gate/weather from stored mock data if not in response
    final gatesStatus = _gatesForAlert(d['alertLevel'] as String? ?? 'Normal');
    final weatherInfo = _weatherForDistrict(d['district'] as String? ?? '');

    return DamModel(
      id: d['id'] as String,
      name: d['name'] as String,
      district: d['district'] as String,
      river: d['river'] as String,
      latitude: (d['latitude'] as num).toDouble(),
      longitude: (d['longitude'] as num).toDouble(),
      maxHeight: maxHeight,
      maxCapacity: maxCapacity,
      currentHeight: curHeight,
      currentStorage: curStorage,
      inflow: inflow,
      outflow: outflow,
      alertLevel: d['alertLevel'] as String? ?? 'Normal',
      gatesStatus: gatesStatus,
      weatherCondition: weatherInfo.$1,
      weatherTemp: weatherInfo.$2,
      historicalData: history,
      isFavorite: false,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Check if backend is running. Returns status info map.
  Future<Map<String, dynamic>> checkBackendStatus() async {
    final base = await _reachableBase();
    if (base == null) {
      return {'running': false, 'base': null, 'damsLoaded': 0};
    }
    try {
      final res = await http
          .get(Uri.parse('$base/api/health'))
          .timeout(const Duration(seconds: 5));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'running': true,
        'base': base,
        'damsLoaded': json['damsLoaded'] ?? 0,
        'bulletinDate': json['bulletinDate'],
        'lastUpdated': json['lastUpdated'],
      };
    } catch (_) {
      return {'running': false, 'base': null, 'damsLoaded': 0};
    }
  }

  /// Fetch dam levels — ONLY from live backend.
  /// Throws [BackendOfflineException] if backend is not running.
  Future<List<DamModel>> fetchDamLevels() async {
    return _fetchFromBackend();
  }

  // ── 7-day history generator (used for both live & mock) ─────────────────
  List<HistoricalDataPoint> _buildHistory({
    required double baseLevel,
    required double baseStorage,
    required double baseInflow,
    required double baseOutflow,
    required double maxHeight,
    required double maxCapacity,
  }) {
    final random = Random();
    final now = DateTime.now();
    List<HistoricalDataPoint> history = [];
    double lvl = baseLevel;
    double str = baseStorage;
    double inf = baseInflow == 0 ? 100 : baseInflow;
    double out = baseOutflow == 0 ? 80 : baseOutflow;

    for (int i = 7; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final drift = (random.nextDouble() * 4.5 - 2.0) / 100.0;

      double hLvl = lvl - (lvl * drift * 0.1);
      double hStr = str - (str * drift);
      hLvl = hLvl.clamp(0, maxHeight);
      hStr = hStr.clamp(0, maxCapacity);

      double hInf = inf * (1 + (random.nextDouble() * 0.3 - 0.15));
      double hOut = out * (1 + (random.nextDouble() * 0.2 - 0.1));

      history.add(
        HistoricalDataPoint(
          date: DateTime(day.year, day.month, day.day),
          level: double.parse(hLvl.toStringAsFixed(2)),
          storage: double.parse(hStr.toStringAsFixed(2)),
          inflow: double.parse(hInf.toStringAsFixed(1)),
          outflow: double.parse(hOut.toStringAsFixed(1)),
        ),
      );

      if (i > 0) {
        lvl = hLvl;
        str = hStr;
        inf = hInf;
        out = hOut;
      }
    }
    return history;
  }

  // ── Helper: gates text based on alert ───────────────────────────────────
  String _gatesForAlert(String alert) {
    switch (alert) {
      case 'Danger':
        return '4 Gates Opened (Heavy Discharge!)';
      case 'Warning':
        return '2 Gates Open (discharge of 1,800 cusecs)';
      case 'Watch':
        return '1 Gate Open for Irrigation';
      default:
        return 'Sluice Gates Closed';
    }
  }

  // ── Helper: rough weather per region ────────────────────────────────────
  (String, double) _weatherForDistrict(String district) {
    const map = <String, (String, double)>{
      'Salem': ('Cloudy', 28.5),
      'Erode': ('Sunny', 31.0),
      'Theni': ('Drizzle', 26.0),
      'Coimbatore': ('Cloudy', 27.5),
      'Tenkasi': ('Heavy Rain', 24.5),
      'Tirunelveli': ('Rainy', 25.0),
      'Tiruvannamalai': ('Sunny', 33.0),
      'Krishnagiri': ('Sunny', 32.0),
      'Tiruppur': ('Humid', 29.5),
      'Kanyakumari': ('Rainy', 26.0),
      'Chennai': ('Cloudy', 31.0),
      'Tiruvallur': ('Cloudy', 31.5),
    };
    return map[district] ?? ('Sunny', 30.0);
  }

  // ── Fallback mock data ────────────────────────────────────────────────────
  Future<List<DamModel>> _generateMockDams() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final random = Random();

    final damSpecs = [
      {
        'id': 'mettur',
        'name': 'Mettur Dam (Stanley Reservoir)',
        'district': 'Salem',
        'river': 'Cauvery',
        'lat': 11.7997,
        'lng': 77.8016,
        'maxHeight': 120.0,
        'maxCapacity': 93.47,
        'baseLevel': 102.5,
        'baseStorage': 68.2,
        'baseInflow': 12500.0,
        'baseOutflow': 10000.0,
        'gates': '12 Gates Closed, 4 Sluice Gates Open',
        'weather': 'Cloudy',
        'temp': 28.5,
      },
      {
        'id': 'bhavanisagar',
        'name': 'Bhavanisagar Dam',
        'district': 'Erode',
        'river': 'Bhavani',
        'lat': 11.4674,
        'lng': 77.1264,
        'maxHeight': 105.0,
        'maxCapacity': 32.8,
        'baseLevel': 88.3,
        'baseStorage': 21.5,
        'baseInflow': 3200.0,
        'baseOutflow': 2400.0,
        'gates': 'Normal Flow Sluices Active',
        'weather': 'Sunny',
        'temp': 31.0,
      },
      {
        'id': 'vaigai',
        'name': 'Vaigai Dam',
        'district': 'Theni',
        'river': 'Vaigai',
        'lat': 10.0543,
        'lng': 77.5855,
        'maxHeight': 71.0,
        'maxCapacity': 6.09,
        'baseLevel': 52.0,
        'baseStorage': 3.5,
        'baseInflow': 1800.0,
        'baseOutflow': 1500.0,
        'gates': 'Canal Outflow Active',
        'weather': 'Drizzle',
        'temp': 26.0,
      },
      {
        'id': 'aliyar',
        'name': 'Aliyar Dam',
        'district': 'Coimbatore',
        'river': 'Aliyar',
        'lat': 10.5074,
        'lng': 76.9384,
        'maxHeight': 120.0,
        'maxCapacity': 3.86,
        'baseLevel': 54.0,
        'baseStorage': 0.4,
        'baseInflow': 200.0,
        'baseOutflow': 150.0,
        'gates': 'Sluice Gates Closed',
        'weather': 'Cloudy',
        'temp': 27.5,
      },
      {
        'id': 'sholayar',
        'name': 'Sholayar Dam',
        'district': 'Coimbatore',
        'river': 'Sholayar',
        'lat': 10.4000,
        'lng': 76.9000,
        'maxHeight': 160.0,
        'maxCapacity': 5.05,
        'baseLevel': 84.0,
        'baseStorage': 1.7,
        'baseInflow': 850.0,
        'baseOutflow': 1400.0,
        'gates': 'Spillways Active',
        'weather': 'Cloudy',
        'temp': 25.0,
      },
      {
        'id': 'papanasam',
        'name': 'Papanasam Dam (TN EB Dam)',
        'district': 'Tenkasi',
        'river': 'Thamirabarani',
        'lat': 8.9333,
        'lng': 77.3167,
        'maxHeight': 143.0,
        'maxCapacity': 5.5,
        'baseLevel': 81.0,
        'baseStorage': 2.1,
        'baseInflow': 460.0,
        'baseOutflow': 1500.0,
        'gates': 'Canal Outflow Active',
        'weather': 'Heavy Rain',
        'temp': 24.5,
      },
      {
        'id': 'manimuthar',
        'name': 'Manimuthar Dam',
        'district': 'Tirunelveli',
        'river': 'Manimuthar',
        'lat': 8.8667,
        'lng': 77.3333,
        'maxHeight': 118.0,
        'maxCapacity': 5.51,
        'baseLevel': 74.0,
        'baseStorage': 1.8,
        'baseInflow': 25.0,
        'baseOutflow': 175.0,
        'gates': 'Sluice Gates Closed',
        'weather': 'Rainy',
        'temp': 25.0,
      },
      {
        'id': 'sathanur',
        'name': 'Sathanur Dam',
        'district': 'Tiruvannamalai',
        'river': 'Thenpennai',
        'lat': 12.0167,
        'lng': 79.0833,
        'maxHeight': 119.0,
        'maxCapacity': 7.32,
        'baseLevel': 88.0,
        'baseStorage': 2.2,
        'baseInflow': 100.0,
        'baseOutflow': 80.0,
        'gates': 'Sluice Gates Closed',
        'weather': 'Sunny',
        'temp': 33.0,
      },
      {
        'id': 'krishnagiri',
        'name': 'Krishnagiri Dam (KRP)',
        'district': 'Krishnagiri',
        'river': 'Palarmagalar',
        'lat': 12.4844,
        'lng': 78.2135,
        'maxHeight': 52.0,
        'maxCapacity': 1.67,
        'baseLevel': 50.0,
        'baseStorage': 1.4,
        'baseInflow': 300.0,
        'baseOutflow': 240.0,
        'gates': '1 Gate Open for Irrigation',
        'weather': 'Sunny',
        'temp': 32.0,
      },
      {
        'id': 'amaravathi',
        'name': 'Amaravathi Dam',
        'district': 'Tiruppur',
        'river': 'Amaravathi',
        'lat': 10.3928,
        'lng': 77.2240,
        'maxHeight': 90.0,
        'maxCapacity': 4.05,
        'baseLevel': 46.0,
        'baseStorage': 1.0,
        'baseInflow': 300.0,
        'baseOutflow': 30.0,
        'gates': 'Sluice Gates Closed',
        'weather': 'Humid',
        'temp': 29.5,
      },
      {
        'id': 'pechiparai',
        'name': 'Pechiparai Dam',
        'district': 'Kanyakumari',
        'river': 'Kodayar',
        'lat': 8.2000,
        'lng': 77.3000,
        'maxHeight': 48.0,
        'maxCapacity': 4.35,
        'baseLevel': 34.0,
        'baseStorage': 2.5,
        'baseInflow': 250.0,
        'baseOutflow': 480.0,
        'gates': 'Canal Outflow Active',
        'weather': 'Rainy',
        'temp': 26.0,
      },
      {
        'id': 'perunchani',
        'name': 'Perunchani Dam',
        'district': 'Kanyakumari',
        'river': 'Paralayar',
        'lat': 8.3500,
        'lng': 77.2500,
        'maxHeight': 77.0,
        'maxCapacity': 2.89,
        'baseLevel': 67.0,
        'baseStorage': 2.0,
        'baseInflow': 165.0,
        'baseOutflow': 300.0,
        'gates': 'Canal Outflow Active',
        'weather': 'Rainy',
        'temp': 26.0,
      },
      {
        'id': 'chembarambakkam',
        'name': 'Chembarambakkam Lake',
        'district': 'Chennai',
        'river': 'Adyar Basin',
        'lat': 13.0200,
        'lng': 80.0833,
        'maxHeight': 24.0,
        'maxCapacity': 3.645,
        'baseLevel': 12.0,
        'baseStorage': 1.2,
        'baseInflow': 400.0,
        'baseOutflow': 350.0,
        'gates': 'Closed (Water supply extraction active)',
        'weather': 'Cloudy',
        'temp': 31.0,
      },
      {
        'id': 'redhills',
        'name': 'Red Hills Lake (Puzhal)',
        'district': 'Chennai',
        'river': 'Kosasthalaiyar',
        'lat': 13.1667,
        'lng': 80.1833,
        'maxHeight': 26.4,
        'maxCapacity': 3.3,
        'baseLevel': 13.0,
        'baseStorage': 1.0,
        'baseInflow': 350.0,
        'baseOutflow': 300.0,
        'gates': 'Supply extraction only',
        'weather': 'Cloudy',
        'temp': 31.5,
      },
      {
        'id': 'poondi',
        'name': 'Poondi Reservoir',
        'district': 'Tiruvallur',
        'river': 'Kosasthalaiyar',
        'lat': 13.3333,
        'lng': 79.9833,
        'maxHeight': 53.0,
        'maxCapacity': 9.0,
        'baseLevel': 32.0,
        'baseStorage': 3.5,
        'baseInflow': 800.0,
        'baseOutflow': 700.0,
        'gates': 'Sluice Gates Closed',
        'weather': 'Cloudy',
        'temp': 31.0,
      },
      {
        'id': 'thirumoorthy',
        'name': 'Thirumoorthy Dam',
        'district': 'Tiruppur',
        'river': 'Amaravathi',
        'lat': 10.5700,
        'lng': 77.1200,
        'maxHeight': 60.0,
        'maxCapacity': 1.744,
        'baseLevel': 33.0,
        'baseStorage': 0.73,
        'baseInflow': 445.0,
        'baseOutflow': 1090.0,
        'gates': 'Canal Outflow Active',
        'weather': 'Humid',
        'temp': 29.5,
      },
    ];

    List<DamModel> dams = [];
    for (final spec in damSpecs) {
      final maxHeight = spec['maxHeight'] as double;
      final maxCapacity = spec['maxCapacity'] as double;
      final baseLevel = spec['baseLevel'] as double;
      final baseStorage = spec['baseStorage'] as double;
      final baseInflow = spec['baseInflow'] as double;
      final baseOutflow = spec['baseOutflow'] as double;

      double lvl = baseLevel + (random.nextDouble() * 4 - 2);
      double str = baseStorage + (random.nextDouble() * 2 - 1);
      double inf = baseInflow * (0.9 + random.nextDouble() * 0.2);
      double out = baseOutflow * (0.9 + random.nextDouble() * 0.2);
      lvl = lvl.clamp(0, maxHeight);
      str = str.clamp(0, maxCapacity);

      final history = _buildHistory(
        baseLevel: lvl,
        baseStorage: str,
        baseInflow: inf,
        baseOutflow: out,
        maxHeight: maxHeight,
        maxCapacity: maxCapacity,
      );

      final pct = (str / maxCapacity) * 100;
      String alert = 'Normal';
      if (pct >= 90 && inf > out)
        alert = 'Danger';
      else if (pct >= 80)
        alert = 'Warning';
      else if (pct >= 60)
        alert = 'Watch';

      String gates = spec['gates'] as String;
      if (alert == 'Danger' && gates.toLowerCase().contains('closed')) {
        gates = '4 Gates Opened (Heavy Discharge!)';
      }

      dams.add(
        DamModel(
          id: spec['id'] as String,
          name: spec['name'] as String,
          district: spec['district'] as String,
          river: spec['river'] as String,
          latitude: spec['lat'] as double,
          longitude: spec['lng'] as double,
          maxHeight: maxHeight,
          currentHeight: double.parse(lvl.toStringAsFixed(2)),
          maxCapacity: maxCapacity,
          currentStorage: double.parse(str.toStringAsFixed(3)),
          inflow: double.parse(inf.toStringAsFixed(1)),
          outflow: double.parse(out.toStringAsFixed(1)),
          gatesStatus: gates,
          alertLevel: alert,
          weatherCondition: spec['weather'] as String,
          weatherTemp: spec['temp'] as double,
          historicalData: history,
          isFavorite: false,
        ),
      );
    }
    return dams;
  }
}
