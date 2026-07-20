class BullionRate {
  final String id;
  final String category;
  final String nameEn;
  final String nameTa;
  final String unit;
  final String unitTa;
  final double price;
  final double changeAmount;
  final String changePercentage;
  final bool isPositive;
  final String currency;
  final String location;
  final String updatedAt;

  BullionRate({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameTa,
    required this.unit,
    required this.unitTa,
    required this.price,
    required this.changeAmount,
    required this.changePercentage,
    required this.isPositive,
    required this.currency,
    required this.location,
    required this.updatedAt,
  });

  factory BullionRate.fromJson(Map<String, dynamic> json) {
    return BullionRate(
      id: json['id'] ?? '',
      category: json['category'] ?? 'bullion',
      nameEn: json['nameEn'] ?? '',
      nameTa: json['nameTa'] ?? '',
      unit: json['unit'] ?? '',
      unitTa: json['unitTa'] ?? '',
      price: (json['price'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercentage: json['changePercentage'] ?? '0.0%',
      isPositive: json['isPositive'] ?? true,
      currency: json['currency'] ?? '₹',
      location: json['location'] ?? 'Tamil Nadu',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  String getName(String lang) => lang == 'ta' ? nameTa : nameEn;
  String getUnit(String lang) => lang == 'ta' ? unitTa : unit;
}

class AgriRate {
  final String id;
  final String category;
  final String nameEn;
  final String nameTa;
  final String market;
  final String variety;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String unit;
  final String unitTa;
  final String changePercentage;
  final bool isPositive;
  final String district;
  final String updatedAt;

  AgriRate({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameTa,
    required this.market,
    required this.variety,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.unit,
    required this.unitTa,
    required this.changePercentage,
    required this.isPositive,
    required this.district,
    required this.updatedAt,
  });

  factory AgriRate.fromJson(Map<String, dynamic> json) {
    return AgriRate(
      id: json['id'] ?? '',
      category: json['category'] ?? 'agri',
      nameEn: json['nameEn'] ?? '',
      nameTa: json['nameTa'] ?? '',
      market: json['market'] ?? '',
      variety: json['variety'] ?? '',
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      modalPrice: (json['modalPrice'] as num).toDouble(),
      unit: json['unit'] ?? '₹ / Quintal',
      unitTa: json['unitTa'] ?? 'ரூ / குவிண்டால்',
      changePercentage: json['changePercentage'] ?? '0.0%',
      isPositive: json['isPositive'] ?? true,
      district: json['district'] ?? 'Erode',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  String getName(String lang) => lang == 'ta' ? nameTa : nameEn;
  String getUnit(String lang) => lang == 'ta' ? unitTa : unit;
}
