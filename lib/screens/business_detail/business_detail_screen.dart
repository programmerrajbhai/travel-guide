import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/backend_service.dart';
import '../place_map_screen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Map<String, dynamic> placeData;

  const BusinessDetailScreen({Key? key, required this.placeData}) : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  bool _isSaved = false;
  late Future<List<dynamic>> _placeReviewsFuture;
  late Future<List<dynamic>> _placeItemsFuture;

  int _reviewCount = 0;
  double _averageRating = 5.0;

  @override
  void initState() {
    super.initState();
    final placeName = widget.placeData['name']?.toString() ?? '';

    // Fetching Universal Items (Menus/Products/Facilities)
    _placeItemsFuture = BackendService.fetchItemsForPlace(placeName); // Make sure to add this function in backend_service.dart

    // Fetching and Calculating Reviews
    _placeReviewsFuture = BackendService.fetchReviewsForPlace(placeName);
    _placeReviewsFuture.then((reviews) {
      if (mounted) {
        setState(() {
          _reviewCount = reviews.length;
          if (reviews.isNotEmpty) {
            double total = 0;
            for (var r in reviews) {
              total += (int.tryParse(r['rating'].toString()) ?? 5);
            }
            _averageRating = total / reviews.length;
          } else {
            _averageRating = double.tryParse(widget.placeData['rating']?.toString() ?? '4.5') ?? 4.5;
          }
        });
      }
    });
  }

  void _openDirections() {
    double lat = double.tryParse(widget.placeData['latitude'].toString()) ?? 0.0;
    double lng = double.tryParse(widget.placeData['longitude'].toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceMapScreen(
          placeName: widget.placeData['name']?.toString() ?? 'Place Details',
          latitude: lat,
          longitude: lng,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    final phone = widget.placeData['phone']?.toString() ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available.')));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _launchWebsite() async {
    final website = widget.placeData['website']?.toString() ?? '';
    if (website.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Website not available.')));
      return;
    }
    final Uri launchUri = Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  // স্মার্ট ক্যাটাগরি ট্যাগস
  List<Widget> _buildDynamicFeatureTags(String category) {
    category = category.toLowerCase();
    if (category.contains('masjid') || category.contains('mosque') || category.contains('prayer')) {
      return [
        _buildFeatureTag(Icons.mosque, 'Prayer\nSpace'),
        _buildFeatureTag(Icons.water_drop_outlined, 'Wudu\nArea'),
        _buildFeatureTag(Icons.volume_up_outlined, 'Azan\nBroadcast'),
      ];
    } else if (category.contains('food') || category.contains('restaurant')) {
      return [
        _buildFeatureTag(Icons.verified_user_outlined, 'Halal\nVerified'),
        _buildFeatureTag(Icons.person_outline, 'Muslim\nOwned'),
        _buildFeatureTag(Icons.family_restroom, 'Family\nFriendly'),
      ];
    } else {
      return [
        _buildFeatureTag(Icons.family_restroom, 'Family\nFriendly'),
        _buildFeatureTag(Icons.safety_check_outlined, 'Safe\nArea'),
        _buildFeatureTag(Icons.thumb_up_alt_outlined, 'Highly\nRated'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.placeData['image']?.toString() ?? 'https://via.placeholder.com/400';
    final placeName = widget.placeData['name']?.toString() ?? 'Unknown Place';
    final categoryName = widget.placeData['category_name']?.toString() ?? 'Place';

    String address = widget.placeData['address']?.toString() ?? '';
    if (address.isEmpty) address = '${widget.placeData['latitude'] ?? ''}, ${widget.placeData['longitude'] ?? ''}';
    final openTime = widget.placeData['open_time']?.toString() ?? '10:00 AM - 10:00 PM';
    final priceLevel = widget.placeData['price_level']?.toString() ?? '\$\$';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
          child: ElevatedButton.icon(
            onPressed: _openDirections,
            icon: const Icon(Icons.directions, color: Colors.white),
            label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF115C49),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ================= HERO IMAGE =================
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: Icon(_isSaved ? Icons.favorite : Icons.favorite_border, color: _isSaved ? Colors.red : Colors.white, size: 20),
                    onPressed: () => setState(() => _isSaved = !_isSaved),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[300])),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.2)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE & STATUS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(placeName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Open Now', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ================= RATING =================
                  Row(
                    children: [
                      Text(_averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 4),
                      Row(children: List.generate(5, (index) => Icon(index < _averageRating.round() ? Icons.star : Icons.star_border, color: Colors.orange, size: 16))),
                      const SizedBox(width: 6),
                      Text('($_reviewCount Reviews)', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const Spacer(),
                      Text(priceLevel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ================= CATEGORY & ADDRESS =================
                  Row(
                    children: [
                      const Icon(Icons.category, color: Color(0xFF115C49), size: 16),
                      const SizedBox(width: 6),
                      Text(categoryName, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(address, style: const TextStyle(color: Colors.grey, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ================= ACTIONS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(title: 'Directions', icon: Icons.directions_rounded, isPrimary: true, onTap: _openDirections),
                      _buildActionButton(title: 'Call', icon: Icons.phone_outlined, onTap: _makePhoneCall),
                      _buildActionButton(title: 'Website', icon: Icons.language, onTap: _launchWebsite),
                      _buildActionButton(title: 'Save', icon: _isSaved ? Icons.favorite : Icons.favorite_border, iconColor: _isSaved ? Colors.red : AppColors.textDark, onTap: () => setState(() => _isSaved = !_isSaved)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ================= TAGS =================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(color: const Color(0xFFF2F9F6), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _buildDynamicFeatureTags(categoryName),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ================= ABOUT =================
                  const Text('ABOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Text(
                    widget.placeData['description']?.toString() ?? 'Explore the beauty and services of $placeName. A highly recommended place for everyone.',
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 18, color: AppColors.textDark),
                      const SizedBox(width: 8),
                      Text('Hours: $openTime', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ================= DYNAMIC ITEMS (MENU / PRODUCT / FACILITY) =================
                  FutureBuilder<List<dynamic>>(
                    future: _placeItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF115C49)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

                      final items = snapshot.data!;
                      // Determining section title based on what item type came from DB
                      String sectionTitle = "AVAILABLE ITEMS";
                      if (items[0]['item_type'] == 'menu') sectionTitle = "POPULAR MENU";
                      else if (items[0]['item_type'] == 'product') sectionTitle = "TOP PRODUCTS";
                      else if (items[0]['item_type'] == 'facility') sectionTitle = "FACILITIES";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sectionTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                              const Text('View All', style: TextStyle(color: Color(0xFF115C49), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final hasPrice = item['price'] != null && item['price'].toString().isNotEmpty;
                                return Container(
                                  width: 110,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                    image: item['image'] != null && item['image'].toString().isNotEmpty
                                        ? DecorationImage(image: NetworkImage(item['image'].toString()), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)]
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2),
                                        if (hasPrice) const SizedBox(height: 2),
                                        if (hasPrice) Text(item['price'].toString(), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),

                  // ================= DYNAMIC REVIEWS =================
                  const Text('USER REVIEWS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                  const SizedBox(height: 16),

                  FutureBuilder<List<dynamic>>(
                    future: _placeReviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF115C49))));
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("No reviews yet. Be the first to review!", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      final reviews = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(review['user_image'].toString()),
                                      onBackgroundImageError: (_, __) => const Icon(Icons.person, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(review['user_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const Spacer(),
                                    const Text('Recently', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                    children: List.generate(
                                        int.tryParse(review['rating'].toString()) ?? 5,
                                            (index) => const Icon(Icons.star, color: Colors.orange, size: 14)
                                    )
                                ),
                                const SizedBox(height: 8),
                                Text(review['review_text'].toString(), style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                              ],
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
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({required String title, required IconData icon, bool isPrimary = false, Color? iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF115C49) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isPrimary ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: isPrimary ? Colors.white : (iconColor ?? AppColors.textDark), size: 24),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPrimary ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF115C49), size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.2)),
      ],
    );
  }
}