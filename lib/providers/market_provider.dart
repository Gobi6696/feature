import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../services/market_service.dart';

class MarketProvider extends ChangeNotifier {
  final MarketService _service = MarketService();

  List<BullionRate> _bullionRates = [];
  List<AgriRate> _agriRates = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastUpdated = '';

  List<BullionRate> get bullionRates => _bullionRates;
  List<AgriRate> get agriRates => _agriRates;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get lastUpdated => _lastUpdated;

  Future<void> loadMarketRates({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      final res = await _service.fetchAllMarketRates();
      _bullionRates = List<BullionRate>.from(res['bullion'] ?? []);
      _agriRates = List<AgriRate>.from(res['agri'] ?? []);
      _lastUpdated = res['updatedAt'] ?? '';
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update market prices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
