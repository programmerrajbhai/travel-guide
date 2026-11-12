import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/backend_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _guidesFuture;
  late Future<List<dynamic>> _reviewsFuture;
  late Future<List<dynamic>> _meetupsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  void _fetchAllData() {
    setState(() {
      _guidesFuture = BackendService.fetchGuides().then((value) => value.cast<dynamic>());
      _reviewsFuture = BackendService.fetchReviews().then((value) => value.cast<dynamic>());
      _meetupsFuture = BackendService.fetchMeetups().then((value) => value.cast<dynamic>());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Community',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1B263B), letterSpacing: -0.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryColor, size: 20),
                onPressed: _fetchAllData,
                tooltip: 'Refresh Community',
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: "City Guides"),
            Tab(text: "Reviews"),
            Tab(text: "Meetups"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGuidesTab(),
          _buildReviewsTab(),
          _buildMeetupsTab(),
        ],
      ),
    );
  }

  // ================= 1. City Guides Tab =================
  Widget _buildGuidesTab() {
    return RefreshIndicator(
      onRefresh: () async => _fetchAllData(),
      color: AppColors.primaryColor,
      child: FutureBuilder<List<dynamic>>(
        future: _guidesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(Icons.map_outlined, "No city guides published yet.", "Check back later for new travel guides.");
          }

          final guides = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: guides.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text('Explore Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                );
              }
              final guide = guides[index - 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: NetworkImage(guide['image']?.toString() ?? 'https://via.placeholder.com/600'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
                        child: const Text('CURATED GUIDE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        guide['title']?.toString() ?? 'Untitled Guide',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        guide['subtitle']?.toString() ?? 'By Community',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= 2. User Reviews Tab =================
  Widget _buildReviewsTab() {
    return RefreshIndicator(
      onRefresh: () async => _fetchAllData(),
      color: AppColors.primaryColor,
      child: FutureBuilder<List<dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(Icons.rate_review_outlined, "No reviews yet.", "Be the first to share your experience!");
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              int rating = int.tryParse(review['rating']?.toString() ?? '5') ?? 5;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: NetworkImage(review['user_image']?.toString() ?? 'https://via.placeholder.com/150'),
                          onBackgroundImageError: (e, s) {},
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review['user_name']?.toString() ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                              const SizedBox(height: 2),
                              Text("Reviewed ${review['place_name']}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      review['review_text']?.toString() ?? '',
                      style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= 3. Meetups Tab =================
  Widget _buildMeetupsTab() {
    return RefreshIndicator(
      onRefresh: () async => _fetchAllData(),
      color: AppColors.primaryColor,
      child: FutureBuilder<List<dynamic>>(
        future: _meetupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(Icons.groups_outlined, "No upcoming meetups.", "Host a meetup from the Admin Panel.");
          }

          final meetups = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: meetups.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upcoming Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('${meetups.length} Meetups', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                );
              }
              final meetup = meetups[index - 1];
              return _buildMeetupCard(meetup);
            },
          );
        },
      ),
    );
  }

  Widget _buildMeetupCard(dynamic meetup) {
    String rawDate = meetup['date']?.toString() ?? 'TBA';
    String datePart1 = rawDate.split(' ').isNotEmpty ? rawDate.split(' ')[0] : '';
    String datePart2 = rawDate.split(' ').length > 1 ? rawDate.split(' ')[1].replaceAll(',', '') : '';

    return GestureDetector(
      onTap: () => _showMeetupDetailsSheet(context, meetup),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                meetup['image']?.toString() ?? 'https://via.placeholder.com/600',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 160, color: Colors.grey.shade200, child: const Icon(Icons.event, size: 50, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(datePart1.toUpperCase(), style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(datePart2, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 20)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meetup['title']?.toString() ?? 'Meetup Title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    meetup['location']?.toString() ?? 'Location TBA',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(meetup['host_image']?.toString() ?? ''),
                        onBackgroundImageError: (e, s) {},
                      ),
                      const SizedBox(width: 8),
                      Text("Hosted by ${meetup['host_name']?.toString() ?? 'Admin'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryColor)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= Bottom Sheet for Meetup Details =================
  void _showMeetupDetailsSheet(BuildContext context, dynamic meetup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            meetup['image']?.toString() ?? 'https://via.placeholder.com/600',
                            height: 240, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(height: 240, color: Colors.grey.shade200, child: const Icon(Icons.image, size: 60, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(meetup['title']?.toString() ?? 'Meetup Title', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.2)),
                      ),
                      const SizedBox(height: 24),

                      // Date & Time Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.calendar_month, color: AppColors.primaryColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meetup['date']?.toString() ?? 'Date TBA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text(meetup['time']?.toString() ?? 'Time TBA', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.location_on, color: AppColors.primaryColor, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                  const SizedBox(height: 2),
                                  Text(meetup['location']?.toString() ?? 'Location TBA', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                        child: Divider(height: 1),
                      ),

                      // Host Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: NetworkImage(meetup['host_image']?.toString() ?? ''),
                                onBackgroundImageError: (e,s){}
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Hosted by", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(meetup['host_name']?.toString() ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                              ],
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              child: const Text('Follow', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // About
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("About this meetup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          meetup['description']?.toString() ?? 'No description provided.',
                          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Join Button Fixed at Bottom
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RSVP Confirmed!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Join Meetup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
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

  // ================= Helper: Empty State =================
  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, size: 64, color: AppColors.primaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}