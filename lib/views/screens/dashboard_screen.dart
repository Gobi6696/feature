import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';
import 'ad_screen.dart';
import 'dam_list_screen.dart';
import 'market_screen.dart';
import '../../providers/market_provider.dart';
import '../../models/market_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DamProvider>().loadDams();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DamProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localization.translate('app_title', provider.currentLanguage),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF00C853)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    Localization.translate(
                      'daily_updates',
                      provider.currentLanguage,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF009688), // Solid green-teal
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => provider.toggleLanguage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0288D1), width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.currentLanguage == 'en' ? 'தமிழ்' : 'EN',
                style: const TextStyle(
                  color: Color(0xFF0288D1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () => provider.loadDams(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadDams(showSilently: true),
          color: const Color(0xFF0288D1),
          backgroundColor: Colors.white,
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0288D1)),
                )
              : provider.errorMessage.isNotEmpty
              ? _buildErrorWidget(provider)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // 1. Three Main Feature Navigation Cards (Dams, Gold & Metals, Erode Mandi)
                      _buildThreeCardsSection(provider),
                      const SizedBox(height: 20),

                      // 2. Tamil Nadu Reservoir Overall Storage Overview
                      _buildOverallStatsCard(provider, size),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(DamProvider provider, Size size) {
    final alertCount = provider.dangerAlertCount;
    final warningCount = provider.warningAlertCount;
    final totalPercent = provider.totalStateStoragePercentage;
    final lang = provider.currentLanguage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0F2FE), // Light sky blue
            Color(0xFFF0FDFA), // Light teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBAE6FD), // Sky 200 border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Localization.translate('overall_storage', lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blueGrey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (alertCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF1744).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Color(0xFFFF1744),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$alertCount ${Localization.translate('danger_alerts', lang)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFF1744),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )
              else if (warningCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF9100).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    "$warningCount ${Localization.translate('active_watches', lang)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFF9100),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${provider.totalStateStorage.toStringAsFixed(2)} TMC",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang == 'en'
                          ? "Total storage out of ${provider.totalStateCapacity.toStringAsFixed(2)} TMC capacity"
                          : "மொத்தக் கொள்ளளவு ${provider.totalStateCapacity.toStringAsFixed(2)} TMC-ல் தற்போதைய நீர் இருப்பு",
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Big Storage circle indicators
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: totalPercent / 100.0,
                      strokeWidth: 7,
                      color: const Color(0xFF0288D1),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Text(
                    "${totalPercent.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFBAE6FD), thickness: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localization.translate('total_inflow', lang),
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${provider.totalStateInflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localization.translate('total_outflow', lang),
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 16,
                          color: Colors.teal.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${provider.totalStateOutflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildErrorWidget(DamProvider provider) {
    final lang = provider.currentLanguage;

    // ── Backend is NOT running ──────────────────────────────────────────────
    if (provider.isBackendOffline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Server icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6D00), width: 2),
                ),
                child: const Icon(
                  Icons.dns_rounded,
                  size: 52,
                  color: Color(0xFFFF6D00),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lang == 'en'
                    ? '⚠️ Backend Not Running'
                    : '⚠️ Backend இயங்கவில்லை',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lang == 'en'
                    ? 'The live data scraper server is offline.\nReal dam levels cannot be loaded.'
                    : 'நிஜ தரவு சேவையகம் இயங்கவில்லை.\nதமிழக அணை நிலவரம் ஏற்ற முடியவில்லை.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Terminal command card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.terminal_rounded,
                          size: 14,
                          color: Color(0xFF00E676),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang == 'en'
                              ? 'Start the backend:'
                              : 'சேவையகம் தொடங்க:',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'cd c:\\feature\\scraper',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'npm run dev',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => provider.loadDams(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  lang == 'en' ? 'Check Again' : 'மீண்டும் சரிபார்',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── General error (network, parsing, etc.) ──────────────────────────────
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFFF1744),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadDams(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
              ),
              child: Text(
                Localization.translate('retry', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeCardsSection(DamProvider damProv) {
    final isTa = damProv.currentLanguage == 'ta';
    return Consumer<MarketProvider>(
      builder: (context, marketProv, child) {
        final bullion = marketProv.bullionRates;
        final gold22k = bullion.firstWhere(
          (b) => b.id == 'gold_22k_1g',
          orElse: () => BullionRate(
            id: 'gold_22k_1g',
            category: 'bullion',
            nameEn: 'Gold 22K',
            nameTa: 'தங்கம் 22K',
            unit: '1 Gram',
            unitTa: '1 கிராம்',
            price: 13150.0,
            changeAmount: 15.0,
            changePercentage: '+0.11%',
            isPositive: true,
            currency: '₹',
            location: 'Tamil Nadu',
            updatedAt: '',
          ),
        );

        final silver = bullion.firstWhere(
          (b) => b.id == 'silver_1g',
          orElse: () => BullionRate(
            id: 'silver_1g',
            category: 'bullion',
            nameEn: 'Silver',
            nameTa: 'வெள்ளி',
            unit: '1 Gram',
            unitTa: '1 கிராம்',
            price: 235.0,
            changeAmount: 0.0,
            changePercentage: '0.00%',
            isPositive: true,
            currency: '₹',
            location: 'Tamil Nadu',
            updatedAt: '',
          ),
        );

        final agri = marketProv.agriRates;
        final turmeric = agri.firstWhere(
          (a) => a.id.contains('turmeric'),
          orElse: () => AgriRate(
            id: 'erode_turmeric',
            category: 'agri',
            nameEn: 'Turmeric',
            nameTa: 'விரல் மஞ்சள்',
            market: 'Erode',
            variety: '',
            minPrice: 13800,
            maxPrice: 15450,
            modalPrice: 14700,
            unit: '₹/Quintal',
            unitTa: 'ரூ/குவிண்டால்',
            changePercentage: '+2.1%',
            isPositive: true,
            district: 'Erode',
            updatedAt: '',
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                isTa ? 'முதன்மைச் சேவைகள்' : 'FEATURED SERVICES',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),
            ),

            // CARD 1: Dam Water Levels
            _buildFeatureCard(
              title: isTa ? 'அணை நீர்மட்ட நிலவரம்' : 'Dam Water Levels',
              subtitle: isTa
                  ? 'தமிழக அணைகளின் தற்போதைய நீர் இருப்பு & நீர்வரத்து'
                  : 'Tamil Nadu Reservoir Storage & Flow Data',
              badge: '${damProv.allDams.length} Dams',
              gradientColors: [
                const Color(0xFF0288D1),
                const Color(0xFF0097A7),
              ],
              icon: Icons.water_drop_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DamListScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            // CARD 2: Gold & Metals
            _buildFeatureCard(
              title: isTa ? 'தங்கம் & வெள்ளி நிலவரம்' : 'Gold & Metal Rates',
              subtitle:
                  'Gold 22K: ₹${gold22k.price.toInt()}/g • Silver: ₹${silver.price}/g',
              badge: gold22k.changePercentage,
              gradientColors: [
                const Color(0xFFFF8F00),
                const Color(0xFFFFA000),
              ],
              icon: Icons.workspace_premium_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketScreen(initialIndex: 0),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // CARD 3: Erode Mandi Rates
            _buildFeatureCard(
              title: isTa ? 'ஈரோடு மண்டி நிலவரம்' : 'Erode Mandi Rates',
              subtitle:
                  'Turmeric: ₹${turmeric.modalPrice.toInt()} / Quintal • Rice & Paddy',
              badge: 'Erode Mandi',
              gradientColors: [
                const Color(0xFF2E7D32),
                const Color(0xFF388E3C),
              ],
              icon: Icons.grass_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketScreen(initialIndex: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // CARD 4: Advertisement
            _buildFeatureCard(
              title: isTa ? 'சிறப்பு விளம்பரங்கள்' : 'Advertisement & Deals',
              subtitle: isTa
                  ? 'பிரத்யேக சலுகைகள் & சிறப்பு விளம்பரங்களை பார்க்க'
                  : 'Tap to view exclusive AdMob banners & partner offers',
              badge: 'Ad',
              gradientColors: [
                const Color(0xFF7C4DFF),
                const Color(0xFF651FFF),
              ],
              icon: Icons.campaign_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String badge,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
