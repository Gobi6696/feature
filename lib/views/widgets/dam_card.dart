import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dam_model.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';

class DamCard extends StatelessWidget {
  final DamModel dam;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DamCard({
    super.key,
    required this.dam,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  Color _getAlertColor(String level) {
    switch (level) {
      case 'Danger':
        return const Color(0xFFFF1744); // Vivid red
      case 'Warning':
        return const Color(0xFFFF9100); // Deep orange
      case 'Watch':
        return const Color(0xFFFFD600); // Yellow/Amber
      case 'Normal':
      default:
        return const Color(0xFF00E676); // Vivid emerald green
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DamProvider>();
    final lang = provider.currentLanguage;
    final alertColor = _getAlertColor(dam.alertLevel);

    final palettes = [
      // 1. Light Sky Blue (Mettur Dam)
      const _CardPalette(
        background: Color(0xFFF0F9FF),
        border: Color(0xFFBAE6FD),
        progressStart: Color(0xFF0288D1),
        progressEnd: Color(0xFF38BDF8),
        inflowIconColor: Color(0xFF0288D1),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 2. Light Emerald / Green (Bhavanisagar Dam)
      const _CardPalette(
        background: Color(0xFFF0FDF4),
        border: Color(0xFFBBF7D0),
        progressStart: Color(0xFF10B981),
        progressEnd: Color(0xFF34D399),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF059669),
        gateIconColor: Color(0xFF9333EA),
      ),
      // 3. Light Violet / Purple
      const _CardPalette(
        background: Color(0xFFFAF5FF),
        border: Color(0xFFE9D5FF),
        progressStart: Color(0xFF8B5CF6),
        progressEnd: Color(0xFFC084FC),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 4. Light Amber / Orange
      const _CardPalette(
        background: Color(0xFFFFFBEB),
        border: Color(0xFFFEF3C7),
        progressStart: Color(0xFFF59E0B),
        progressEnd: Color(0xFFFCD34D),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFFD97706),
        gateIconColor: Color(0xFF9333EA),
      ),
      // 5. Light Rose / Pink
      const _CardPalette(
        background: Color(0xFFFFF1F2),
        border: Color(0xFFFECDD3),
        progressStart: Color(0xFFF43F5E),
        progressEnd: Color(0xFFFB7185),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 6. Light Teal
      const _CardPalette(
        background: Color(0xFFF0FDFA),
        border: Color(0xFFCCFBF1),
        progressStart: Color(0xFF0D9488),
        progressEnd: Color(0xFF2DD4BF),
        inflowIconColor: Color(0xFF0288D1),
        outflowIconColor: Color(0xFF0F766E),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 7. Light Fuchsia
      const _CardPalette(
        background: Color(0xFFFDF4FF),
        border: Color(0xFFF5D0FE),
        progressStart: Color(0xFFD946EF),
        progressEnd: Color(0xFFF472B6),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF9333EA),
      ),
      // 8. Light Lime Green
      const _CardPalette(
        background: Color(0xFFF7FEE7),
        border: Color(0xFFECFCCB),
        progressStart: Color(0xFF84CC16),
        progressEnd: Color(0xFFA3E635),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF4D7C0F),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 9. Light Indigo
      const _CardPalette(
        background: Color(0xFFEEF2FF),
        border: Color(0xFFC7D2FE),
        progressStart: Color(0xFF4F46E5),
        progressEnd: Color(0xFF818CF8),
        inflowIconColor: Color(0xFF4338CA),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 10. Light Cyan
      const _CardPalette(
        background: Color(0xFFECFEFF),
        border: Color(0xFFCFFAFE),
        progressStart: Color(0xFF06B6D4),
        progressEnd: Color(0xFF22D3EE),
        inflowIconColor: Color(0xFF0891B2),
        outflowIconColor: Color(0xFF059669),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 11. Light Peach / Orange
      const _CardPalette(
        background: Color(0xFFFFF7ED),
        border: Color(0xFFFFEDD5),
        progressStart: Color(0xFFFF7849),
        progressEnd: Color(0xFFFF9F43),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFFC2410C),
        gateIconColor: Color(0xFF9333EA),
      ),
      // 12. Light Sand / Gold
      const _CardPalette(
        background: Color(0xFFFEFCE8),
        border: Color(0xFFFEF9C3),
        progressStart: Color(0xFFCA8A04),
        progressEnd: Color(0xFFFDE047),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF059669),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 13. Light Slate / Bluegrey
      const _CardPalette(
        background: Color(0xFFF8FAFC),
        border: Color(0xFFE2E8F0),
        progressStart: Color(0xFF64748B),
        progressEnd: Color(0xFF94A3B8),
        inflowIconColor: Color(0xFF0288D1),
        outflowIconColor: Color(0xFF0D9488),
        gateIconColor: Color(0xFF7C3AED),
      ),
      // 14. Light Pink / Ruby Lavender
      const _CardPalette(
        background: Color(0xFFFFF5F5),
        border: Color(0xFFFFE3E3),
        progressStart: Color(0xFFE11D48),
        progressEnd: Color(0xFFFDA4AF),
        inflowIconColor: Color(0xFF2563EB),
        outflowIconColor: Color(0xFF9F1239),
        gateIconColor: Color(0xFF9333EA),
      ),
    ];

    final allDamsIndex = provider.allDams.indexWhere((element) => element.id == dam.id);
    final paletteIndex = allDamsIndex != -1 ? allDamsIndex % palettes.length : 0;
    final palette = palettes[paletteIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: palette.progressStart.withOpacity(0.05),
            highlightColor: palette.progressStart.withOpacity(0.02),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name, Alert Badge & Favorite Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Localization.translateDamName(dam.id, dam.name, lang),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${Localization.translateDistrict(dam.district, lang)} | ${Localization.translateRiver(dam.river, lang)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Alert Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: alertColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: alertColor.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          Localization.translate(dam.alertLevel.toLowerCase(), lang).toUpperCase(),
                          style: TextStyle(
                            color: alertColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Favorite button
                      GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Icon(
                          dam.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: dam.isFavorite ? const Color(0xFFFFB300) : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: palette.border, height: 24, thickness: 1),
                  
                  // Row 2: Visual storage line indicator & text numbers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${dam.currentStorage.toStringAsFixed(2)} / ${dam.maxCapacity.toStringAsFixed(2)} ${Localization.translate('tmc', lang)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${dam.currentHeight.toStringAsFixed(1)} / ${dam.maxHeight.toStringAsFixed(1)} ${Localization.translate('ft', lang)}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: palette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 8,
                        width: MediaQuery.of(context).size.width * 
                            0.78 * (dam.storagePercentage / 100.0), // Responsive scaling estimation
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [palette.progressStart, palette.progressEnd],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Inflow, Outflow and Gates Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Inflow
                      Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 14, color: palette.inflowIconColor),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.translate('inflow_rate', lang).toUpperCase(),
                                style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${dam.inflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Outflow
                      Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 14, color: palette.outflowIconColor),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.translate('outflow_rate', lang).toUpperCase(),
                                style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${dam.outflow.toStringAsFixed(0)} ${Localization.translate('cusecs', lang)}",
                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Gates status
                      Row(
                        children: [
                          Icon(Icons.door_sliding_outlined, size: 14, color: palette.gateIconColor),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.translate('gates_status', lang).toUpperCase(),
                                style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  Localization.translateGates(dam.gatesStatus, lang),
                                  style: const TextStyle(
                                    fontSize: 11, 
                                    color: Colors.black87, 
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPalette {
  final Color background;
  final Color border;
  final Color progressStart;
  final Color progressEnd;
  final Color inflowIconColor;
  final Color outflowIconColor;
  final Color gateIconColor;

  const _CardPalette({
    required this.background,
    required this.border,
    required this.progressStart,
    required this.progressEnd,
    required this.inflowIconColor,
    required this.outflowIconColor,
    required this.gateIconColor,
  });
}
