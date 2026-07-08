class HistoricalDataPoint {
  final DateTime date;
  final double level; // in feet
  final double storage; // in TMC
  final double inflow; // in cusecs
  final double outflow; // in cusecs

  const HistoricalDataPoint({
    required this.date,
    required this.level,
    required this.storage,
    required this.inflow,
    required this.outflow,
  });

  factory HistoricalDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalDataPoint(
      date: DateTime.parse(json['date'] as String),
      level: (json['level'] as num).toDouble(),
      storage: (json['storage'] as num).toDouble(),
      inflow: (json['inflow'] as num).toDouble(),
      outflow: (json['outflow'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'level': level,
      'storage': storage,
      'inflow': inflow,
      'outflow': outflow,
    };
  }
}

class DamModel {
  final String id;
  final String name;
  final String district;
  final String river;
  final double latitude;
  final double longitude;
  final double maxHeight; // in feet
  final double currentHeight; // in feet
  final double maxCapacity; // in TMC
  final double currentStorage; // in TMC
  final double inflow; // in cusecs
  final double outflow; // in cusecs
  final String gatesStatus; // e.g., "Closed", "3 Gates Open"
  final String alertLevel; // "Normal", "Watch", "Warning", "Danger"
  final String weatherCondition; // e.g., "Sunny", "Rainy"
  final double weatherTemp; // in Celsius
  final List<HistoricalDataPoint> historicalData;
  final bool isFavorite;

  const DamModel({
    required this.id,
    required this.name,
    required this.district,
    required this.river,
    required this.latitude,
    required this.longitude,
    required this.maxHeight,
    required this.currentHeight,
    required this.maxCapacity,
    required this.currentStorage,
    required this.inflow,
    required this.outflow,
    required this.gatesStatus,
    required this.alertLevel,
    required this.weatherCondition,
    required this.weatherTemp,
    required this.historicalData,
    this.isFavorite = false,
  });

  // Calculate storage percentage
  double get storagePercentage {
    if (maxCapacity <= 0) return 0.0;
    final percentage = (currentStorage / maxCapacity) * 100;
    return percentage > 100.0 ? 100.0 : (percentage < 0.0 ? 0.0 : percentage);
  }

  // Calculate level height percentage
  double get heightPercentage {
    if (maxHeight <= 0) return 0.0;
    final percentage = (currentHeight / maxHeight) * 100;
    return percentage > 100.0 ? 100.0 : (percentage < 0.0 ? 0.0 : percentage);
  }

  DamModel copyWith({
    String? id,
    String? name,
    String? district,
    String? river,
    double? latitude,
    double? longitude,
    double? maxHeight,
    double? currentHeight,
    double? maxCapacity,
    double? currentStorage,
    double? inflow,
    double? outflow,
    String? gatesStatus,
    String? alertLevel,
    String? weatherCondition,
    double? weatherTemp,
    List<HistoricalDataPoint>? historicalData,
    bool? isFavorite,
  }) {
    return DamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      river: river ?? this.river,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxHeight: maxHeight ?? this.maxHeight,
      currentHeight: currentHeight ?? this.currentHeight,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentStorage: currentStorage ?? this.currentStorage,
      inflow: inflow ?? this.inflow,
      outflow: outflow ?? this.outflow,
      gatesStatus: gatesStatus ?? this.gatesStatus,
      alertLevel: alertLevel ?? this.alertLevel,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherTemp: weatherTemp ?? this.weatherTemp,
      historicalData: historicalData ?? this.historicalData,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory DamModel.fromJson(Map<String, dynamic> json) {
    return DamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      district: json['district'] as String,
      river: json['river'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      maxHeight: (json['maxHeight'] as num).toDouble(),
      currentHeight: (json['currentHeight'] as num).toDouble(),
      maxCapacity: (json['maxCapacity'] as num).toDouble(),
      currentStorage: (json['currentStorage'] as num).toDouble(),
      inflow: (json['inflow'] as num).toDouble(),
      outflow: (json['outflow'] as num).toDouble(),
      gatesStatus: json['gatesStatus'] as String,
      alertLevel: json['alertLevel'] as String,
      weatherCondition: json['weatherCondition'] as String,
      weatherTemp: (json['weatherTemp'] as num).toDouble(),
      historicalData:
          (json['historicalData'] as List<dynamic>?)
              ?.map(
                (e) => HistoricalDataPoint.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'river': river,
      'latitude': latitude,
      'longitude': longitude,
      'maxHeight': maxHeight,
      'currentHeight': currentHeight,
      'maxCapacity': maxCapacity,
      'currentStorage': currentStorage,
      'inflow': inflow,
      'outflow': outflow,
      'gatesStatus': gatesStatus,
      'alertLevel': alertLevel,
      'weatherCondition': weatherCondition,
      'weatherTemp': weatherTemp,
      'historicalData': historicalData.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }
}
