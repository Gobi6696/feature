import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dam_provider.dart';
import '../../utils/localization.dart';
import '../widgets/dam_card.dart';
import 'compare_screen.dart';
import 'dam_detail_screen.dart';

class DamListScreen extends StatefulWidget {
  const DamListScreen({super.key});

  @override
  State<DamListScreen> createState() => _DamListScreenState();
}

class _DamListScreenState extends State<DamListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DamProvider>();
    final isTa = provider.currentLanguage == 'ta';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTa ? 'தமிழக அணை நிலவரங்கள்' : 'Tamil Nadu Dam Levels',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              isTa ? 'அனைத்து அணைகளின் நேரடி நீர்மட்டம்' : 'Real-time reservoir storage & flows',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFF0288D1),
            ),
            tooltip: Localization.translate('compare_dams', provider.currentLanguage),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompareScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () => provider.loadDams(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadDams(showSilently: true),
          color: const Color(0xFF0288D1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: Localization.translate('search_placeholder', provider.currentLanguage),
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0288D1)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              provider.updateSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // District Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.districts.length,
                    itemBuilder: (context, index) {
                      final dist = provider.districts[index];
                      final isSelected = provider.selectedDistrict == dist;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            dist == 'All' ? (isTa ? 'அனைத்தும்' : 'All Districts') : dist,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0288D1),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (_) => provider.setDistrictFilter(dist),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Dam Cards List
                provider.dams.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            isTa ? 'அணைகள் எதுவும் காணப்படவில்லை' : 'No reservoirs found',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.dams.length,
                        itemBuilder: (context, index) {
                          final dam = provider.dams[index];
                          return DamCard(
                            dam: dam,
                            onFavoriteToggle: () => provider.toggleFavorite(dam.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DamDetailScreen(damId: dam.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
