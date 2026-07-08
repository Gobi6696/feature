import 'package:flutter/material.dart';
import '../models/dam_model.dart';
import '../services/dam_service.dart';

class DamProvider extends ChangeNotifier {
  final DamService _damService = DamService();

  List<DamModel> _allDams = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isBackendOffline = false;   // true when Node.js scraper is not running
  String _searchQuery = '';
  String _selectedDistrict = 'All';
  String _selectedAlertFilter = 'All';
  String _sortBy = 'capacity';
  bool _sortAscending = false;
  final Set<String> _favoriteIds = {};
  String _currentLanguage = 'en';

  // Getters
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  bool get isBackendOffline => _isBackendOffline;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedDistrict => _selectedDistrict;
  String get selectedAlertFilter => _selectedAlertFilter;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  List<DamModel> get allDams => _allDams;

  // Filtered and Sorted Dams list
  List<DamModel> get dams {
    List<DamModel> filtered = _allDams.map((dam) {
      return dam.copyWith(isFavorite: _favoriteIds.contains(dam.id));
    }).toList();

    // 1. Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((dam) {
        return dam.name.toLowerCase().contains(query) ||
            dam.district.toLowerCase().contains(query) ||
            dam.river.toLowerCase().contains(query);
      }).toList();
    }

    // 2. District Filter
    if (_selectedDistrict != 'All') {
      filtered = filtered.where((dam) => dam.district == _selectedDistrict).toList();
    }

    // 3. Alert Level Filter
    if (_selectedAlertFilter != 'All') {
      filtered = filtered.where((dam) => dam.alertLevel == _selectedAlertFilter).toList();
    }

    // 4. Sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'capacity':
          comparison = a.maxCapacity.compareTo(b.maxCapacity);
          break;
        case 'level_percentage':
          comparison = a.storagePercentage.compareTo(b.storagePercentage);
          break;
        case 'inflow':
          comparison = a.inflow.compareTo(b.inflow);
          break;
        case 'outflow':
          comparison = a.outflow.compareTo(b.outflow);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  // Get list of unique districts for filtering dropdown
  List<String> get districts {
    final Set<String> uniqueDistricts = {'All'};
    for (var dam in _allDams) {
      uniqueDistricts.add(dam.district);
    }
    final list = uniqueDistricts.toList();
    list.sort();
    // Keep 'All' at the top
    list.remove('All');
    return ['All', ...list];
  }

  // Aggregate stats of TN
  double get totalStateCapacity {
    return _allDams.fold(0.0, (sum, dam) => sum + dam.maxCapacity);
  }

  double get totalStateStorage {
    return _allDams.fold(0.0, (sum, dam) => sum + dam.currentStorage);
  }

  double get totalStateStoragePercentage {
    final cap = totalStateCapacity;
    if (cap <= 0) return 0.0;
    return (totalStateStorage / cap) * 100;
  }

  double get totalStateInflow {
    return _allDams.fold(0.0, (sum, dam) => sum + dam.inflow);
  }

  double get totalStateOutflow {
    return _allDams.fold(0.0, (sum, dam) => sum + dam.outflow);
  }

  int get dangerAlertCount {
    return _allDams.where((dam) => dam.alertLevel == 'Danger').length;
  }

  int get warningAlertCount {
    return _allDams.where((dam) => dam.alertLevel == 'Warning' || dam.alertLevel == 'Watch').length;
  }

  // Initialize and Fetch
  Future<void> loadDams({bool showSilently = false}) async {
    if (!showSilently) {
      _isLoading = true;
      _errorMessage = '';
      _isBackendOffline = false;
      notifyListeners();
    }

    try {
      final fetched = await _damService.fetchDamLevels();
      _allDams = fetched;
      _errorMessage = '';
      _isBackendOffline = false;
    } on BackendOfflineException catch (e) {
      _isBackendOffline = true;
      _errorMessage = e.message;
    } catch (e) {
      _isBackendOffline = false;
      _errorMessage = 'Unexpected error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // State manipulation methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDistrictFilter(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setAlertFilter(String alert) {
    _selectedAlertFilter = alert;
    notifyListeners();
  }

  void setSortBy(String criteria) {
    if (_sortBy == criteria) {
      _sortAscending = !_sortAscending; // Toggle direction
    } else {
      _sortBy = criteria;
      _sortAscending = false; // Default descending for sizes
      if (criteria == 'name') {
        _sortAscending = true; // Default alphabetical ascending
      }
    }
    notifyListeners();
  }

  void toggleFavorite(String damId) {
    if (_favoriteIds.contains(damId)) {
      _favoriteIds.remove(damId);
    } else {
      _favoriteIds.add(damId);
    }
    notifyListeners();
  }

  bool isFavorite(String damId) {
    return _favoriteIds.contains(damId);
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDistrict = 'All';
    _selectedAlertFilter = 'All';
    _sortBy = 'capacity';
    _sortAscending = false;
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ta' : 'en';
    notifyListeners();
  }

  void setLanguage(String lang) {
    if (lang == 'en' || lang == 'ta') {
      _currentLanguage = lang;
      notifyListeners();
    }
  }
}
