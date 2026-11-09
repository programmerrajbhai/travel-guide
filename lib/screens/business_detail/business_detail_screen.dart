import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../place_map_screen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Map<String, dynamic> placeData;

  const BusinessDetailScreen({Key? key, required this.placeData}) : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  bool _isSaved = false;

  // ডার্ট কম্পাইলার যেন কনফিউজড না হয় তাই টাইপ ইনফারেন্স ব্যবহার করা হয়েছে
  final _popularMenu = [
    {'name': 'Chicken Biryani', 'price': '\$12.99', 'image': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'},
    {'name': 'Beef Kebab', 'price': '\$11.99', 'image': 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'},
    {'name': 'Beef Curry', 'price': '\$13.99', 'image': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'},
    {'name': 'Desserts', 'price': '\$6.99', 'image': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'},
  ];

  final _reviews = [
    {'name': 'Ali Khan', 'time': '2 days ago', 'rating': 5, 'text': 'Excellent food, great service and very clean environment.'},
    {'name': 'Mariam Noor', 'time': '1 week ago', 'rating': 5, 'text': 'Absolutely loved the authentic taste. Highly recommended for families.'},
  ];

  // ম্যাপ ওপেন করার ফাংশন
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

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.placeData['image']?.toString() ?? widget.placeData['image_url']?.toString() ?? 'https://via.placeholder.com/400';
    final placeName = widget.placeData['name']?.toString() ?? 'Unknown Place';
    final distance = widget.placeData['distance'] != null ? "${(widget.placeData['distance'] as double).toStringAsFixed(1)} mi" : "0.6 mi";

    return Scaffold(
      backgroundColor: Colors.white,
      // নিচের স্টিকি 'Get Directions' বাটন
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
          // টপ হিরো ইমেজ সেকশন
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
                    onPressed: () {
                      setState(() => _isSaved = !_isSaved); // সেভ/আনসেভ লজিক
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.white, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share option clicked')));
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.1)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // বিস্তারিত তথ্যের সেকশন
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Open Tag
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

                  // Rating Row
                  Row(
                    children: [
                      const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 4),
                      Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 16))),
                      const SizedBox(width: 6),
                      const Text('(312 Reviews)', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                      const Spacer(),
                      const Text('\$\$', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Categories
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.placeData['category_name']?.toString() ?? 'Pakistani • Indian • Middle Eastern', style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textLight, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text('233 Lark St, Albany, NY 12210 • $distance', style: const TextStyle(color: AppColors.textLight, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (4 grid row)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(title: 'Directions', icon: Icons.directions_rounded, isPrimary: true, onTap: _openDirections),
                      _buildActionButton(title: 'Call', icon: Icons.phone_outlined, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling...')))),
                      _buildActionButton(title: 'Website', icon: Icons.language, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Website...')))),
                      _buildActionButton(title: 'Save', icon: _isSaved ? Icons.favorite : Icons.favorite_border, iconColor: _isSaved ? Colors.red : AppColors.textDark, onTap: () {
                        setState(() => _isSaved = !_isSaved);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Halal Features Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(color: const Color(0xFFF2F9F6), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeatureTag(Icons.verified_user_outlined, 'Halal\nVerified'),
                            _buildFeatureTag(Icons.person_outline, 'Muslim\nOwned'),
                            _buildFeatureTag(Icons.family_restroom, 'Family\nFriendly'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10),
                            _buildFeatureTag(Icons.mosque, 'Prayer Space'),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  const Text('ABOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Text(
                    widget.placeData['description']?.toString() ?? 'Delicious halal food made with fresh ingredients.\nDine-in, Takeaway & Catering available.',
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.access_time_outlined, size: 18, color: AppColors.textDark),
                      SizedBox(width: 8),
                      Text('Open Daily: 10:00 AM - 10:00 PM', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Popular Menu Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('POPULAR MENU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                      Text('View All', style: TextStyle(color: Color(0xFF115C49), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularMenu.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final menu = _popularMenu[index];
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          // String casting added to prevent "Object? to String" errors
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(menu['image'].toString()), fit: BoxFit.cover)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(menu['name'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2),
                                const SizedBox(height: 2),
                                Text(menu['price'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Reviews Section
                  const Text('REVIEWS (312)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                                const SizedBox(width: 10),
                                // String casting added
                                Text(review['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const Spacer(),
                                Text(review['time'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 14))),
                            const SizedBox(height: 8),
                            Text(review['text'].toString(), style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper Widget for 4 Action Buttons
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

  // Helper Widget for Halal Tags
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