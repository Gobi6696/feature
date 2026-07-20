import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dam_provider.dart';
import '../../providers/market_provider.dart';
import '../../models/market_model.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().loadMarketRates(silent: false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final damProv = context.watch<DamProvider>();
    final isTa = damProv.currentLanguage == 'ta';
    final marketProv = context.watch<MarketProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTa ? 'நேரடி சந்தை நிலவரம்' : 'Live Market Rates',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              isTa ? 'தங்கம், வெள்ளி & ஈரோடு மண்டி' : 'Gold, Silver & Erode Mandi',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0288D1)),
            onPressed: () {
              context.read<MarketProvider>().loadMarketRates(silent: false);
            },
            tooltip: isTa ? 'புதுப்பி' : 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0288D1),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF0288D1),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(Icons.workspace_premium_rounded, size: 20),
              text: isTa ? 'தங்கம் & வெள்ளி' : 'Gold & Metals',
            ),
            Tab(
              icon: const Icon(Icons.grass_rounded, size: 20),
              text: isTa ? 'ஈரோடு மண்டி' : 'Erode Mandi Rates',
            ),
          ],
        ),
      ),
      body: marketProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0288D1)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBullionTab(marketProv.bullionRates, isTa),
                _buildAgriTab(marketProv.agriRates, isTa),
              ],
            ),
    );
  }

  Widget _buildBullionTab(List<BullionRate> rates, bool isTa) {
    if (rates.isEmpty) {
      return Center(
        child: Text(
          isTa ? 'சந்தை விவரங்கள் ஏற்றப்படவில்லை' : 'No bullion rates loaded',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0288D1),
      onRefresh: () =>
          context.read<MarketProvider>().loadMarketRates(silent: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB300),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.diamond_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTa
                            ? 'தமிழ்நாடு நேரடி ஆபரண விலை'
                            : 'Tamil Nadu Bullion Benchmark',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTa
                            ? 'தினசரி நேரலை விலை மாற்றம் (ஜி.எஸ்.டி தவிர்த்து)'
                            : 'Updated daily with live market trend badges',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF795548),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...rates.map((rate) => _buildBullionCard(rate, isTa)),
        ],
      ),
    );
  }

  Widget _buildBullionCard(BullionRate rate, bool isTa) {
    final isGold = rate.id.startsWith('gold');
    final isSilver = rate.id.startsWith('silver');

    final Color accentColor = isGold
        ? const Color(0xFFFF8F00)
        : isSilver
            ? const Color(0xFF607D8B)
            : const Color(0xFF7E57C2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isGold
                  ? Icons.workspace_premium_rounded
                  : isSilver
                      ? Icons.monetization_on_rounded
                      : Icons.auto_awesome_rounded,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.getName(isTa ? 'ta' : 'en'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rate.getUnit(isTa ? 'ta' : 'en')} • ${rate.location}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${rate.price.toStringAsFixed(rate.price % 1 == 0 ? 0 : 2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rate.isPositive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rate.isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: rate.isPositive
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rate.changePercentage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: rate.isPositive
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgriTab(List<AgriRate> rates, bool isTa) {
    if (rates.isEmpty) {
      return Center(
        child: Text(
          isTa ? 'மண்டி விவரங்கள் ஏற்றப்படவில்லை' : 'No Agri rates loaded',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0288D1),
      onRefresh: () =>
          context.read<MarketProvider>().loadMarketRates(silent: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTa
                            ? 'ஈரோடு வேளாண் ஒழுங்குமுறை விற்பனைக்கூடம்'
                            : 'Erode Regulated Market (Agmarknet)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTa
                            ? 'மஞ்சள் & நெல் தினசரி ஏல வரத்து சந்தை விலை'
                            : 'Daily live auction trade rates per quintal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF33691E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...rates.map((rate) => _buildAgriCard(rate, isTa)),
        ],
      ),
    );
  }

  Widget _buildAgriCard(AgriRate rate, bool isTa) {
    final isTurmeric = rate.id.contains('turmeric');

    final Color accentColor = isTurmeric
        ? const Color(0xFFF57F17)
        : const Color(0xFF388E3C);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isTurmeric ? Icons.local_florist_rounded : Icons.rice_bowl_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.getName(isTa ? 'ta' : 'en'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rate.market,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rate.changePercentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceMetric(
                label: isTa ? 'குறைந்தபட்சம்' : 'Min Price',
                value: '₹${rate.minPrice.toStringAsFixed(0)}',
                color: Colors.black54,
              ),
              _buildPriceMetric(
                label: isTa ? 'சராசரி (Modal)' : 'Modal Price',
                value: '₹${rate.modalPrice.toStringAsFixed(0)}',
                color: accentColor,
                isBold: true,
              ),
              _buildPriceMetric(
                label: isTa ? 'அதிகபட்சம்' : 'Max Price',
                value: '₹${rate.maxPrice.toStringAsFixed(0)}',
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceMetric({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
