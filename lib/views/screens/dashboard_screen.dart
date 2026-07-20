import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';
import '../widgets/dam_card.dart';
import 'compare_screen.dart';
import 'dam_detail_screen.dart';
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
            icon: const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFF0288D1),
              size: 28,
            ),
            tooltip: Localization.translate(
              'compare_dams',
              provider.currentLanguage,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompareScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFFF8F00),
              size: 26,
            ),
            tooltip: provider.currentLanguage == 'ta'
                ? 'நேரடி சந்தை நிலவரம்'
                : 'Market Rates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketScreen()),
              );
            },
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
                      // 1. Overall State Reservoir Storage Panel
                      _buildOverallStatsCard(provider, size),
                      const SizedBox(height: 12),

                      // 1b. Live Market Rates Ticker Card
                      _buildMarketBanner(provider),
                      const SizedBox(height: 16),

                      // 2. Search Bar
                      _buildSearchBar(provider),
                      const SizedBox(height: 16),

                      // 3. District Horizontal Chips Filter
                      _buildDistrictFilters(provider),
                      const SizedBox(height: 12),

                      // 4. Alert Level Filter Row
                      _buildAlertFilters(provider),
                      const SizedBox(height: 16),

                      // 5. Header: Dams list + Sort Actions
                      _buildSortHeader(provider),
                      const SizedBox(height: 12),

                      // 6. Dam Cards List
                      provider.dams.isEmpty
                          ? _buildEmptyStateWidget(provider)
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.dams.length,
                              itemBuilder: (context, index) {
                                final dam = provider.dams[index];
                                return DamCard(
                                  dam: dam,
                                  onFavoriteToggle: () =>
                                      provider.toggleFavorite(dam.id),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DamDetailScreen(damId: dam.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                      const SizedBox(height: 40),
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
              Text(
                Localization.translate('overall_storage', lang),
                style: TextStyle(
                  color: Colors.blueGrey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              if (alertCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF1744).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Color(0xFFFF1744),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$alertCount ${Localization.translate('danger_alerts', lang)}",
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
                    color: const Color(0xFFFF9100).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF9100).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    "$warningCount ${Localization.translate('active_watches', lang)}",
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

  Widget _buildSearchBar(DamProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black87),
        onChanged: provider.updateSearchQuery,
        decoration: InputDecoration(
          hintText: Localization.translate(
            'search_bar_hint',
            provider.currentLanguage,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.black54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    provider.updateSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictFilters(DamProvider provider) {
    final districts = provider.districts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            Localization.translate('filter_district', provider.currentLanguage),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: districts.length,
            itemBuilder: (context, index) {
              final district = districts[index];
              final isSelected = provider.selectedDistrict == district;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    Localization.translateDistrict(
                      district,
                      provider.currentLanguage,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => provider.setDistrictFilter(district),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  selectedColor: const Color(0xFF0288D1),
                  backgroundColor: const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertFilters(DamProvider provider) {
    final alertFilters = ['All', 'Danger', 'Warning', 'Watch', 'Normal'];
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alertFilters.length,
        itemBuilder: (context, index) {
          final alert = alertFilters[index];
          final isSelected = provider.selectedAlertFilter == alert;
          Color chipColor = const Color(0xFFF1F5F9);
          Color textColor = Colors.black87;

          if (isSelected) {
            textColor = Colors.white;
            if (alert == 'All') {
              chipColor = const Color(0xFF0288D1);
            } else if (alert == 'Danger') {
              chipColor = const Color(0xFFFF1744);
            } else if (alert == 'Warning') {
              chipColor = const Color(0xFFFF9100);
            } else if (alert == 'Watch') {
              chipColor = const Color(0xFFFFD600);
              textColor = Colors.black87;
            } else {
              chipColor = const Color(0xFF00C853);
            }
          }

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => provider.setAlertFilter(alert),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  Localization.translate(
                    alert.toLowerCase(),
                    provider.currentLanguage,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortHeader(DamProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "${Localization.translate('reservoirs_count', provider.currentLanguage)} (${provider.dams.length})",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  "${Localization.translate('sort_by', provider.currentLanguage)}: ${_getSortLabel(provider.sortBy, provider.currentLanguage)}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0288D1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                provider.sortAscending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: const Color(0xFF0288D1),
                size: 14,
              ),
            ],
          ),
          onSelected: provider.setSortBy,
          color: Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'capacity',
              child: Text(
                Localization.translate(
                  'capacity_limit',
                  provider.currentLanguage,
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            PopupMenuItem(
              value: 'level_percentage',
              child: Text(
                Localization.translate(
                  'level_percentage',
                  provider.currentLanguage,
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            PopupMenuItem(
              value: 'inflow',
              child: Text(
                Localization.translate('inflow_rate', provider.currentLanguage),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            PopupMenuItem(
              value: 'outflow',
              child: Text(
                Localization.translate(
                  'outflow_rate',
                  provider.currentLanguage,
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            PopupMenuItem(
              value: 'name',
              child: Text(
                Localization.translate(
                  'alphabetical',
                  provider.currentLanguage,
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getSortLabel(String key, String lang) {
    switch (key) {
      case 'name':
        return Localization.translate('alphabetical', lang);
      case 'level_percentage':
        return Localization.translate('storage_percentage', lang);
      case 'inflow':
        return Localization.translate('inflow_rate', lang);
      case 'outflow':
        return Localization.translate('outflow_rate', lang);
      case 'capacity':
      default:
        return Localization.translate('capacity_limit', lang);
    }
  }

  Widget _buildEmptyStateWidget(DamProvider provider) {
    final lang = provider.currentLanguage;
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waves_rounded, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            Localization.translate('no_reservoirs', lang),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == 'en'
                ? "Try clearing your search queries or filter choices."
                : "தேடல் மற்றும் வடிப்பான்களை மாற்றி மீண்டும் முயலவும்.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: provider.clearFilters,
            icon: const Icon(Icons.clear_all_rounded, color: Colors.white),
            label: Text(
              Localization.translate('reset_filters', lang),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

  Widget _buildMarketBanner(DamProvider damProv) {
    final isTa = damProv.currentLanguage == 'ta';
    return Consumer<MarketProvider>(
      builder: (context, marketProv, child) {
        final bullion = marketProv.bullionRates;
        final gold22k1g = bullion.firstWhere(
          (b) => b.id == 'gold_22k_1g',
          orElse: () => BullionRate(
            id: 'gold_22k_1g',
            category: 'bullion',
            nameEn: 'Gold 22K',
            nameTa: 'தங்கம் 22K',
            unit: '1 Gram',
            unitTa: '1 கிராம்',
            price: 6765.0,
            changeAmount: 40.0,
            changePercentage: '+0.60%',
            isPositive: true,
            currency: '₹',
            location: 'TN',
            updatedAt: '',
          ),
        );

        final silver1g = bullion.firstWhere(
          (b) => b.id == 'silver_1g',
          orElse: () => BullionRate(
            id: 'silver_1g',
            category: 'bullion',
            nameEn: 'Silver',
            nameTa: 'வெள்ளி',
            unit: '1 Gram',
            unitTa: '1 கிராம்',
            price: 93.5,
            changeAmount: 0.8,
            changePercentage: '+0.86%',
            isPositive: true,
            currency: '₹',
            location: 'TN',
            updatedAt: '',
          ),
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarketScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFE8F5E9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFFFF8F00),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isTa ? 'நேரடி சந்தை' : 'Live Market Rates',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8F00),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isTa ? 'நேரலை' : 'LIVE',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gold: ₹${gold22k1g.price.toInt()}/g  •  Silver: ₹${silver1g.price}/g  •  Erode Turmeric',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
