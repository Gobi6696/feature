import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_model.dart';

class MarketService {
  static const String _productionUrl = 'https://feature-kbn0.onrender.com';
  static const String _localBase = 'http://localhost:3001';
  static const String _emulatorBase = 'http://10.0.2.2:3001';

  Future<String?> _reachableBase() async {
    for (final base in [_productionUrl, _localBase, _emulatorBase]) {
      try {
        final uri = Uri.parse('$base/api/health');
        final res = await http.get(uri).timeout(const Duration(seconds: 15));
        if (res.statusCode == 200) return base;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchAllMarketRates() async {
    try {
      final base = await _reachableBase();
      if (base != null) {
        final uri = Uri.parse('$base/api/market/all');
        final res = await http.get(uri).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          if (json['success'] == true) {
            final List<dynamic> bullionRaw = json['bullion'] ?? [];
            final List<dynamic> agriRaw = json['agri'] ?? [];

            final bullionList = bullionRaw
                .map((b) => BullionRate.fromJson(b))
                .toList();
            final agriList = agriRaw.map((a) => AgriRate.fromJson(a)).toList();

            return {
              'bullion': bullionList,
              'agri': agriList,
              'updatedAt':
                  json['lastUpdated'] ?? DateTime.now().toIso8601String(),
            };
          }
        }
      }
    } catch (e) {
      // Return fallback benchmark data if backend offline
    }

    return _getFallbackData();
  }

  Map<String, dynamic> _getFallbackData() {
    final now = DateTime.now().toIso8601String();
    return {
      'bullion': [
        BullionRate(
          id: 'gold_24k_1g',
          category: 'bullion',
          nameEn: 'Gold 24K (99.9% Pure)',
          nameTa: 'தங்கம் 24 கேரட் (1 கிராம்)',
          unit: '1 Gram',
          unitTa: '1 கிராம்',
          price: 13808.0,
          changeAmount: 16.0,
          changePercentage: '+0.12%',
          isPositive: true,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
        BullionRate(
          id: 'gold_22k_1g',
          category: 'bullion',
          nameEn: 'Gold 22K (Jewellery)',
          nameTa: 'ஆபரணத் தங்கம் 22 கேரட் (1 கிராம்)',
          unit: '1 Gram',
          unitTa: '1 கிராம்',
          price: 13150.0,
          changeAmount: 15.0,
          changePercentage: '+0.11%',
          isPositive: true,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
        BullionRate(
          id: 'gold_22k_8g',
          category: 'bullion',
          nameEn: 'Gold 22K Sovereign (1 Pavan)',
          nameTa: 'ஆபரணத் தங்கம் (1 பவுன் / 8 கிராம்)',
          unit: '8 Grams (1 Pavan)',
          unitTa: '8 கிராம் (1 பவுன்)',
          price: 105200.0,
          changeAmount: 120.0,
          changePercentage: '+0.11%',
          isPositive: true,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
        BullionRate(
          id: 'silver_1g',
          category: 'bullion',
          nameEn: 'Silver (Fine 999)',
          nameTa: 'வெள்ளி (1 கிராம்)',
          unit: '1 Gram',
          unitTa: '1 கிராம்',
          price: 235.0,
          changeAmount: 0.0,
          changePercentage: '0.00%',
          isPositive: true,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
        BullionRate(
          id: 'silver_1kg',
          category: 'bullion',
          nameEn: 'Silver Bar (1 Kg)',
          nameTa: 'வெள்ளி கட்டி (1 கிலோ)',
          unit: '1 Kg',
          unitTa: '1 கிலோ',
          price: 235000.0,
          changeAmount: 0.0,
          changePercentage: '0.00%',
          isPositive: true,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
        BullionRate(
          id: 'platinum_1g',
          category: 'bullion',
          nameEn: 'Platinum',
          nameTa: 'பிளாட்டினம் (1 கிராம்)',
          unit: '1 Gram',
          unitTa: '1 கிராம்',
          price: 3650.0,
          changeAmount: -10.0,
          changePercentage: '-0.27%',
          isPositive: false,
          currency: '₹',
          location: 'Tamil Nadu',
          updatedAt: now,
        ),
      ],
      'agri': [
        AgriRate(
          id: 'erode_turmeric_finger',
          category: 'agri',
          nameEn: 'Erode Turmeric (Finger / விரல் மஞ்சள்)',
          nameTa: 'ஈரோடு விரல் மஞ்சள்',
          market: 'Erode Regulated Market (ஈரோடு மண்டி)',
          variety: 'Finger Variety',
          minPrice: 13800.0,
          maxPrice: 15450.0,
          modalPrice: 14700.0,
          unit: '₹ / Quintal (100kg)',
          unitTa: 'ரூ / குவிண்டால்',
          changePercentage: '+2.1%',
          isPositive: true,
          district: 'Erode',
          updatedAt: now,
        ),
        AgriRate(
          id: 'erode_turmeric_bulb',
          category: 'agri',
          nameEn: 'Erode Turmeric (Bulb / கிழங்கு மஞ்சள்)',
          nameTa: 'ஈரோடு கிழங்கு மஞ்சள்',
          market: 'Erode Regulated Market (ஈரோடு மண்டி)',
          variety: 'Bulb Variety',
          minPrice: 12200.0,
          maxPrice: 13900.0,
          modalPrice: 13150.0,
          unit: '₹ / Quintal (100kg)',
          unitTa: 'ரூ / குவிண்டால்',
          changePercentage: '+1.4%',
          isPositive: true,
          district: 'Erode',
          updatedAt: now,
        ),
        AgriRate(
          id: 'erode_rice_ponni',
          category: 'agri',
          nameEn: 'Erode Rice (Ponni / பொன்னி அரிசி)',
          nameTa: 'ஈரோடு பொன்னி அரிசி',
          market: 'Erode Grain Market (ஈரோடு தானிய சந்தை)',
          variety: 'Fine Variety',
          minPrice: 4800.0,
          maxPrice: 5600.0,
          modalPrice: 5200.0,
          unit: '₹ / Quintal (100kg)',
          unitTa: 'ரூ / குவிண்டால்',
          changePercentage: '0.0%',
          isPositive: true,
          district: 'Erode',
          updatedAt: now,
        ),
        AgriRate(
          id: 'erode_paddy_common',
          category: 'agri',
          nameEn: 'Paddy / Rough Rice (நெல்)',
          nameTa: 'நெல் (ஈரோடு மண்டி)',
          market: 'Erode APMC Market',
          variety: 'Paddy Grade A',
          minPrice: 2180.0,
          maxPrice: 2450.0,
          modalPrice: 2320.0,
          unit: '₹ / Quintal (100kg)',
          unitTa: 'ரூ / குவிண்டால்',
          changePercentage: '+0.8%',
          isPositive: true,
          district: 'Erode',
          updatedAt: now,
        ),
      ],
      'updatedAt': now,
    };
  }
}
