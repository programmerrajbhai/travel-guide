import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/backend_service.dart';
import '../category_places_screen.dart';
import '../place_map_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<dynamic>> _placesFuture;
  late Future<List<dynamic>> _categoriesFuture;
  String _searchQuery = "";
  String _selectedCategoryId = "";

  final List<Color> _bgColors = [
    Colors.green.withOpacity(0.15),
    Colors.orange.withOpacity(0.15),
    Colors.blue.withOpacity(0.15),
    Colors.purple.withOpacity(0.15),
    Colors.teal.withOpacity(0.15),
    Colors.red.withOpacity(0.15),
  ];

  final List<Color> _iconColors = [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _placesFuture = BackendService.fetchPlaces();
      _categoriesFuture = BackendService.fetchCategories();
    });
  }

  // Smart Filtering Logic
  List<dynamic> _filterPlaces(List<dynamic> places) {
    return places.where((place) {
      final nameMatches = place['name'].toString().toLowerCase().contains(_searchQuery);
      final categoryMatches = _selectedCategoryId.isEmpty || place['category_id'].toString() == _selectedCategoryId;
      return nameMatches && categoryMatches;
    }).toList();
  }

  void _showFilterOptions(BuildContext context, List<dynamic> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Filter by Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: [
                        FilterChip(
                          label: const Text("All"),
                          selected: _selectedCategoryId.isEmpty,
                          selectedColor: AppColors.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppColors.primaryColor,
                          onSelected: (bool selected) {
                            setModalState(() => _selectedCategoryId = "");
                            setState(() => _selectedCategoryId = "");
                            Navigator.pop(context);
                          },
                        ),
                        ...categories.map((cat) {
                          return FilterChip(
                            label: Text(cat['name'].toString()),
                            selected: _selectedCategoryId == cat['id'].toString(),
                            selectedColor: AppColors.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryColor,
                            onSelected: (bool selected) {
                              setModalState(() => _selectedCategoryId = selected ? cat['id'].toString() : "");
                              setState(() => _selectedCategoryId = selected ? cat['id'].toString() : "");
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  void _showPlaceDetailsBottomSheet(BuildContext context, dynamic place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 5, width: 50,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    place['image']?.toString() ?? 'https://via.placeholder.com/400',
                    height: 220, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 220, color: Colors.grey[200], child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place['name']?.toString() ?? 'Unknown Place',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        place['category_name']?.toString() ?? 'Place',
                        style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place['address']?.toString() ?? "${place['latitude']}, ${place['longitude']}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("About this place", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    place['description']?.toString() ?? 'No description available.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
                          double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PlaceMapScreen(placeName: place['name'], latitude: lat, longitude: lng)
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF115C49),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Get Directions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async { _fetchData(); },
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 8),
                  child: Text(
                    'Where to next?',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1B263B), letterSpacing: -0.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Discover halal-friendly destinations around the world.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 24),

                // ================= SEARCH & FILTER =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FutureBuilder<List<dynamic>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        final categories = snapshot.data ?? [];
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                                ),
                                child: TextField(
                                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                                  decoration: InputDecoration(
                                    hintText: 'Search places...',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 22),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                if (categories.isNotEmpty) {
                                  _showFilterOptions(context, categories);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _selectedCategoryId.isEmpty ? const Color(0xFF115C49) : Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: const Color(0xFF115C49).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: const Icon(Icons.tune, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                ),
                const SizedBox(height: 32),

                // ================= DYNAMIC CATEGORIES =================
                FutureBuilder<List<dynamic>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                    final categories = snapshot.data!;
                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CategoryPlacesScreen(
                                          categoryId: cat['id'].toString(),
                                          categoryName: cat['name'].toString(),
                                        )
                                    )
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 65, height: 65,
                                      decoration: BoxDecoration(
                                        color: _bgColors[index % _bgColors.length],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          cat['icon']?.toString() ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c,e,s) => Icon(Icons.category, color: _iconColors[index % _iconColors.length], size: 28),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        cat['name']?.toString() ?? '',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // ================= PLACES RESULTS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_searchQuery.isEmpty && _selectedCategoryId.isEmpty ? 'Trending Destinations' : 'Search Results',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1B263B))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<dynamic>>(
                  future: _placesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No places found.")));
                    }

                    final filteredPlaces = _filterPlaces(snapshot.data!);

                    if (filteredPlaces.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text("No matches found.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                              if (_selectedCategoryId.isNotEmpty)
                                TextButton(
                                    onPressed: () => setState(() { _searchQuery = ""; _selectedCategoryId = ""; }),
                                    child: const Text("Clear Filters", style: TextStyle(color: AppColors.primaryColor))
                                )
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];
                          return GestureDetector(
                            onTap: () => _showPlaceDetailsBottomSheet(context, place),
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                image: DecorationImage(
                                  image: NetworkImage(place['image']?.toString() ?? 'https://via.placeholder.com/400'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.8)],
                                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12, right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.star, color: Colors.amber, size: 12),
                                          SizedBox(width: 4),
                                          Text("4.9", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16, left: 16, right: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place['name']?.toString() ?? 'Name',
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                place['category_name']?.toString() ?? 'Category',
                                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100), // Bottom padding for Nav Bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}