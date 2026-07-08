import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dam_model.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String? _selectedDamIdA;
  String? _selectedDamIdB;

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
    final allDams = provider.allDams;
    final lang = provider.currentLanguage;

    if (allDams.length < 2) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(Localization.translate('compare_title', lang)),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            Localization.translate('need_two_dams', lang),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      );
    }

    // Default selections
    _selectedDamIdA ??= allDams[0].id;
    _selectedDamIdB ??= allDams[1].id;

    final damA = allDams.firstWhere((d) => d.id == _selectedDamIdA);
    final damB = allDams.firstWhere((d) => d.id == _selectedDamIdB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Localization.translate('compare_title', lang),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Selector Panel
            _buildSelectorPanel(allDams, lang),

            // 2. Comparative Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Visual side-by-side liquid comparison bars
                    _buildLiquidCompareMeters(damA, damB, lang),
                    const SizedBox(height: 24),

                    // Metrics Comparison Grid
                    _buildComparisonRows(damA, damB, lang),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorPanel(List<DamModel> allDams, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          // Select Dam A
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.translate('reservoir_a', lang),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDamIdA,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0288D1),
                      ),
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDamIdA = val);
                      },
                      items: allDams.map((dam) {
                        return DropdownMenuItem<String>(
                          value: dam.id,
                          child: Text(
                            Localization.translateDamName(
                              dam.id,
                              dam.name,
                              lang,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          // VS divider
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0288D1).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Text(
              "VS",
              style: TextStyle(
                color: Color(0xFF0288D1),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Select Dam B
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.translate('reservoir_b', lang),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDamIdB,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0288D1),
                      ),
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDamIdB = val);
                      },
                      items: allDams.map((dam) {
                        return DropdownMenuItem<String>(
                          value: dam.id,
                          child: Text(
                            Localization.translateDamName(
                              dam.id,
                              dam.name,
                              lang,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidCompareMeters(DamModel damA, DamModel damB, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            Localization.translate('cap_percent_compare', lang),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Dam A Gauge
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: damA.storagePercentage / 100,
                            strokeWidth: 8,
                            color: const Color(0xFF0288D1),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        Text(
                          "${damA.storagePercentage.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Localization.translateDamName(damA.id, damA.name, lang),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Dam B Gauge
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: damB.storagePercentage / 100,
                            strokeWidth: 8,
                            color: const Color(0xFF00C853),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        Text(
                          "${damB.storagePercentage.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Localization.translateDamName(damB.id, damB.name, lang),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildComparisonRows(DamModel damA, DamModel damB, String lang) {
    final tmc = Localization.translate('tmc', lang);
    final ft = Localization.translate('ft', lang);
    final cusecs = Localization.translate('cusecs', lang);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          // Table Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    Localization.translate('metric', lang),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    Localization.translateDamName(damA.id, damA.name, lang),
                    style: const TextStyle(
                      color: Color(0xFF0288D1),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    Localization.translateDamName(damB.id, damB.name, lang),
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 1),

          _buildCompareRow(
            Localization.translate('district_loc', lang),
            Localization.translateDistrict(damA.district, lang),
            Localization.translateDistrict(damB.district, lang),
          ),
          _buildCompareRow(
            Localization.translate('river_basin', lang),
            Localization.translateRiver(damA.river, lang),
            Localization.translateRiver(damB.river, lang),
          ),

          _buildCompareRow(
            Localization.translate('max_cap', lang),
            "${damA.maxCapacity} $tmc",
            "${damB.maxCapacity} $tmc",
            highlightHigher: true,
            valA: damA.maxCapacity,
            valB: damB.maxCapacity,
          ),
          _buildCompareRow(
            Localization.translate('current_storage', lang),
            "${damA.currentStorage} $tmc",
            "${damB.currentStorage} $tmc",
            highlightHigher: true,
            valA: damA.currentStorage,
            valB: damB.currentStorage,
          ),
          _buildCompareRow(
            Localization.translate('max_limit', lang),
            "${damA.maxHeight} $ft",
            "${damB.maxHeight} $ft",
            highlightHigher: true,
            valA: damA.maxHeight,
            valB: damB.maxHeight,
          ),
          _buildCompareRow(
            Localization.translate('level', lang),
            "${damA.currentHeight} $ft",
            "${damB.currentHeight} $ft",
            highlightHigher: true,
            valA: damA.currentHeight,
            valB: damB.currentHeight,
          ),
          _buildCompareRow(
            Localization.translate('inflow_rate', lang),
            "${damA.inflow.toStringAsFixed(0)} $cusecs",
            "${damB.inflow.toStringAsFixed(0)} $cusecs",
            highlightHigher: true,
            valA: damA.inflow,
            valB: damB.inflow,
          ),
          _buildCompareRow(
            Localization.translate('outflow_rate', lang),
            "${damA.outflow.toStringAsFixed(0)} $cusecs",
            "${damB.outflow.toStringAsFixed(0)} $cusecs",
            highlightHigher: true,
            valA: damA.outflow,
            valB: damB.outflow,
          ),

          _buildAlertCompareRow(damA, damB, lang),
          _buildGateCompareRow(damA, damB, lang),
        ],
      ),
    );
  }

  Widget _buildCompareRow(
    String metric,
    String valTextA,
    String valTextB, {
    bool highlightHigher = false,
    double? valA,
    double? valB,
  }) {
    bool isAHigher = false;
    bool isBHigher = false;

    if (highlightHigher && valA != null && valB != null) {
      if (valA > valB) isAHigher = true;
      if (valB > valA) isBHigher = true;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Label
              Expanded(
                flex: 3,
                child: Text(
                  metric,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Val A
              Expanded(
                flex: 4,
                child: Text(
                  valTextA,
                  style: TextStyle(
                    color: isAHigher ? const Color(0xFF0288D1) : Colors.black87,
                    fontSize: 11,
                    fontWeight: isAHigher ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              // Val B
              Expanded(
                flex: 4,
                child: Text(
                  valTextB,
                  style: TextStyle(
                    color: isBHigher ? const Color(0xFF0288D1) : Colors.black87,
                    fontSize: 11,
                    fontWeight: isBHigher ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFE2E8F0), height: 1),
      ],
    );
  }

  Widget _buildAlertCompareRow(DamModel damA, DamModel damB, String lang) {
    final alertColorA = _getAlertColor(damA.alertLevel);
    final alertColorB = _getAlertColor(damB.alertLevel);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  Localization.translate('alert_level', lang),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // A Alert
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: alertColorA.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: alertColorA.withOpacity(0.4)),
                    ),
                    child: Text(
                      Localization.translate(
                        damA.alertLevel.toLowerCase(),
                        lang,
                      ),
                      style: TextStyle(
                        color: alertColorA,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // B Alert
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: alertColorB.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: alertColorB.withOpacity(0.4)),
                    ),
                    child: Text(
                      Localization.translate(
                        damB.alertLevel.toLowerCase(),
                        lang,
                      ),
                      style: TextStyle(
                        color: alertColorB,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFE2E8F0), height: 1),
      ],
    );
  }

  Widget _buildGateCompareRow(DamModel damA, DamModel damB, String lang) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  Localization.translate('gates_status', lang),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // A Gates
              Expanded(
                flex: 4,
                child: Text(
                  Localization.translateGates(damA.gatesStatus, lang),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // B Gates
              Expanded(
                flex: 4,
                child: Text(
                  Localization.translateGates(damB.gatesStatus, lang),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
