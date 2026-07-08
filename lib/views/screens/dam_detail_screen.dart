import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dam_model.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';
import '../widgets/wave_widget.dart';
import '../widgets/trend_chart.dart';

class DamDetailScreen extends StatefulWidget {
  final String damId;

  const DamDetailScreen({super.key, required this.damId});

  @override
  State<DamDetailScreen> createState() => _DamDetailScreenState();
}

class _DamDetailScreenState extends State<DamDetailScreen> {
  bool _showStorageTrend = true;

  Color _getAlertColor(String level) {
    switch (level) {
      case 'Danger':
        return const Color(0xFFFF1744);
      case 'Warning':
        return const Color(0xFFFF9100);
      case 'Watch':
        return const Color(0xFFFFD600);
      case 'Normal':
      default:
        return const Color(0xFF00E676);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DamProvider>();
    // Locate the current dam from the provider list
    final damIndex = provider.allDams.indexWhere(
      (element) => element.id == widget.damId,
    );

    if (damIndex == -1) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(
          child: Text(
            "Dam data not found.",
            style: TextStyle(color: Colors.black87),
          ),
        ),
      );
    }

    final dam = provider.allDams[damIndex];
    final lang = provider.currentLanguage;
    final isFav = provider.isFavorite(dam.id);
    final alertColor = _getAlertColor(dam.alertLevel);

    // Inflow vs Outflow dynamic indicator
    final flowDelta = dam.inflow - dam.outflow;
    final isRising = flowDelta > 0;
    final isStable = flowDelta == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Dynamic Header AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                Localization.translateDamName(dam.id, dam.name, lang),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFav ? const Color(0xFFFFB300) : Colors.black87,
                ),
                onPressed: () => provider.toggleFavorite(dam.id),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Scrollable Info Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 1. Water Level Visual Indicator Section
                  Center(
                    child: Hero(
                      tag: 'wave-${dam.id}',
                      child: WaveWidget(
                        percentage: dam.storagePercentage,
                        size: 220,
                        waterColor: const Color(0xFF0288D1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Alert & Flow Trend Summary Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: alertColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: alertColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          "${Localization.translate(dam.alertLevel.toLowerCase(), lang).toUpperCase()} ${Localization.translate('status', lang)}",
                          style: TextStyle(
                            color: alertColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isStable
                              ? Colors.grey.withOpacity(0.15)
                              : isRising
                              ? Colors.blue.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isStable
                                ? Colors.grey.withOpacity(0.3)
                                : isRising
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isStable
                                  ? Icons.remove_rounded
                                  : isRising
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: isStable
                                  ? Colors.grey.shade700
                                  : isRising
                                  ? Colors.blue.shade800
                                  : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isStable
                                  ? Localization.translate('stable', lang)
                                  : isRising
                                  ? Localization.translate('rising', lang)
                                  : Localization.translate('falling', lang),
                              style: TextStyle(
                                color: isStable
                                    ? Colors.grey.shade700
                                    : isRising
                                    ? Colors.blue.shade800
                                    : Colors.orange.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Grid of Main stats (Height, Storage, Inflow, Outflow)
                  _buildStatsGrid(dam, lang),
                  const SizedBox(height: 20),

                  // 4. Geographical and River Details Card
                  _buildMetadataCard(dam, lang),
                  const SizedBox(height: 20),

                  // 5. Interactive Chart Toggle and Trend View
                  _buildTrendSection(dam, lang),
                  const SizedBox(height: 20),

                  // 6. Sluice Gates & Weather details
                  _buildStatusRow(dam, lang),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DamModel dam, String lang) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          Localization.translate('level', lang),
          "${dam.currentHeight} ${Localization.translate('ft', lang)}",
          "${Localization.translate('max_limit', lang)}: ${dam.maxHeight} ${Localization.translate('ft', lang)}",
          Icons.height_rounded,
          Colors.blue,
        ),
        _buildStatCard(
          Localization.translate('current_storage', lang),
          "${dam.currentStorage} ${Localization.translate('tmc', lang)}",
          "${Localization.translate('max_cap', lang)}: ${dam.maxCapacity} ${Localization.translate('tmc', lang)}",
          Icons.layers_rounded,
          Colors.teal,
        ),
        _buildStatCard(
          Localization.translate('inflow_rate', lang),
          "${dam.inflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
          Localization.translate('vol_sec', lang),
          Icons.arrow_downward_rounded,
          Colors.indigo,
        ),
        _buildStatCard(
          Localization.translate('outflow_rate', lang),
          "${dam.outflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
          Localization.translate('vol_sec', lang),
          Icons.arrow_upward_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subLabel,
    IconData icon,
    Color color,
  ) {
    final cardBgColor = color.withOpacity(0.08);
    final cardBorderColor = color.withOpacity(0.22);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.9)),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(DamModel dam, String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Localization.translate('geo_specs', lang),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 20),
          _buildMetaRow(
            Localization.translate('river_basin', lang),
            Localization.translateRiver(dam.river, lang),
          ),
          _buildMetaRow(
            Localization.translate('district_loc', lang),
            Localization.translateDistrict(dam.district, lang),
          ),
          _buildMetaRow(
            Localization.translate('gps_coords', lang),
            "${dam.latitude.toStringAsFixed(4)}° N, ${dam.longitude.toStringAsFixed(4)}° E",
          ),
          const SizedBox(height: 12),
          // Coordinate link visual
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${Localization.translate('copied_coords', lang)}: ${dam.latitude}, ${dam.longitude}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0288D1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0288D1).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    size: 16,
                    color: Color(0xFF0288D1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Localization.translate('view_map', lang),
                    style: const TextStyle(
                      color: Color(0xFF0288D1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(DamModel dam, String lang) {
    return Column(
      children: [
        // Tab selectors
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => setState(() => _showStorageTrend = true),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _showStorageTrend
                      ? const Color(0xFF0288D1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _showStorageTrend
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  Localization.translate('storage_cap', lang),
                  style: TextStyle(
                    color: _showStorageTrend ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => setState(() => _showStorageTrend = false),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: !_showStorageTrend
                      ? const Color(0xFF0288D1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: !_showStorageTrend
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  Localization.translate('water_height', lang),
                  style: TextStyle(
                    color: !_showStorageTrend ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Custom Bezier Trend Graph
        TrendChart(
          history: dam.historicalData,
          showStorage: _showStorageTrend,
          lineColor: _showStorageTrend
              ? const Color(0xFF0288D1)
              : const Color(0xFF00C853),
        ),
      ],
    );
  }

  Widget _buildStatusRow(DamModel dam, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sluice gates
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.door_sliding_outlined,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localization.translate('sluice_gates', lang),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Localization.translateGates(dam.gatesStatus, lang),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weather
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  dam.weatherCondition.toLowerCase().contains("rain")
                      ? Icons.umbrella_rounded
                      : Icons.wb_sunny_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localization.translate('site_weather', lang),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${dam.weatherTemp.toStringAsFixed(1)}°C - ${Localization.translateWeather(dam.weatherCondition, lang)}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
