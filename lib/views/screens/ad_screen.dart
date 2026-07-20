import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../providers/dam_provider.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Provided AdMob Banner Ad Unit ID
  static const String _adUnitId = 'ca-app-pub-9848688753999400/8959996807';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdMob Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final damProv = context.watch<DamProvider>();
    final isTa = damProv.currentLanguage == 'ta';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          isTa ? 'சிறப்பு விளம்பரங்கள்' : 'Advertisement & Offers',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top AdMob Banner Unit Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.campaign_rounded,
                            color: Color(0xFF7C4DFF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTa ? 'விளம்பரம்' : 'Sponsored Banner',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C4DFF),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Ad',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C4DFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isAdLoaded && _bannerAd != null)
                    SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    )
                  else
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7C4DFF),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTa
                                  ? 'விளம்பரம் ஏற்றப்படுகிறது...'
                                  : 'Loading AdMob Advertisement...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Partner Offers Header
            Text(
              isTa ? 'சிறப்புச் சலுகைகள்' : 'Featured Partner Deals',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Offer Card 1: Agri Supplies
            _buildOfferCard(
              title: isTa ? 'விவசாய உரங்கள் & விதைகள்' : 'Agri Inputs & Seeds Discount',
              description: isTa
                  ? 'ஈரோடு & சுற்றியுள்ள பகுதிகளுக்கான சிறப்புத் தள்ளுபடி சலுகைகள்'
                  : 'Special discounts on certified paddy seeds & organic fertilizers',
              badge: 'UP TO 20% OFF',
              gradientColors: [const Color(0xFF2E7D32), const Color(0xFF43A047)],
              icon: Icons.grass_rounded,
            ),

            const SizedBox(height: 12),

            // Offer Card 2: Bullion & Jewellery
            _buildOfferCard(
              title: isTa ? 'ஆபரண தங்கம் & வெள்ளி சேதாரம் தள்ளுபடி' : 'Jewellery Making Charge Off',
              description: isTa
                  ? 'பிரபல நகைக் கடைகளின் சிறப்புத் தள்ளுபடி சலுகைகள்'
                  : 'Zero making charges on 22K Gold Sovereign purchases this week',
              badge: 'SPECIAL OFFER',
              gradientColors: [const Color(0xFFFF8F00), const Color(0xFFFFA000)],
              icon: Icons.workspace_premium_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String description,
    required String badge,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
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
          color: gradientColors[0].withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gradientColors[0].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: gradientColors[0], size: 28),
          ),
          const SizedBox(width: 14),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: gradientColors[0],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
