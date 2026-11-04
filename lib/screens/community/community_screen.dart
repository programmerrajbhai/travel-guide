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
  late Future<dynamic> _guidesFuture;
  late Future<dynamic> _reviewsFuture;
  late Future<dynamic> _meetupsFuture; // Live Meetups Future

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // shob data live database theke asche
    _guidesFuture = BackendService.fetchGuides();
    _reviewsFuture = BackendService.fetchReviews();
    _meetupsFuture = BackendService.fetchMeetups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _guidesFuture = BackendService.fetchGuides();
      _reviewsFuture = BackendService.fetchReviews();
      _meetupsFuture = BackendService.fetchMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
              child: IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textDark),
                onPressed: _refreshData,
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF115C49),
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: const Color(0xFF115C49),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: "Guides"),
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

  // ================= 1. Real Database Guides Tab =================
  Widget _buildGuidesTab() {
    return FutureBuilder<dynamic>(
      future: _guidesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        if (snapshot.hasError) return const Center(child: Text("Error loading guides."));
        if (!snapshot.hasData || snapshot.data.isEmpty) return const Center(child: Text("No guides available right now.", style: TextStyle(color: Colors.grey)));

        final guides = snapshot.data;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Trending City Guides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: guides.length,
                  itemBuilder: (context, index) {
                    final guide = guides[index];
                    return _buildGuideCard(
                      title: guide['title'] ?? 'Unknown Guide',
                      subtitle: guide['subtitle'] ?? 'Community Curated',
                      image: guide['image'] ?? 'https://via.placeholder.com/600',
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Curated Collections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark))),
              const SizedBox(height: 16),
              _buildCollectionCard(title: 'Top Historic Mosques', image: 'https://images.unsplash.com/photo-1564121211835-e88c852648ab?q=80&w=600&auto=format&fit=crop', placesCount: '10 Places'),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ================= 2. Real Database Reviews Tab =================
  Widget _buildReviewsTab() {
    return FutureBuilder<dynamic>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        if (snapshot.hasError) return const Center(child: Text("Error loading reviews."));
        if (!snapshot.hasData || snapshot.data.isEmpty) return const Center(child: Text("Be the first to leave a review!", style: TextStyle(color: Colors.grey)));

        final reviews = snapshot.data;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final reviewData = reviews[index];
            int rating = int.tryParse(reviewData['rating'].toString()) ?? 5;
            String time = 'Recently';
            if (reviewData['created_at'] != null) {
              try {
                DateTime date = DateTime.parse(reviewData['created_at']);
                time = "${date.day}/${date.month}/${date.year}";
              } catch (e) {}
            }
            return _buildReviewCard(
              userName: reviewData['user_name'] ?? 'Anonymous',
              userImage: reviewData['user_image'] ?? 'https://via.placeholder.com/150',
              placeName: reviewData['place_name'] ?? 'Destination',
              time: time,
              rating: rating,
              review: reviewData['review_text'] ?? '',
            );
          },
        );
      },
    );
  }

  // ================= 3. Real Database Meetups Tab =================
  Widget _buildMeetupsTab() {
    return FutureBuilder<dynamic>(
      future: _meetupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        if (snapshot.hasError) return const Center(child: Text("Error loading meetups."));

        final meetups = snapshot.data ?? [];

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: meetups.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Meetups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ElevatedButton(
                      onPressed: () {}, // Admin function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF115C49),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('+ Host', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  ],
                ),
              );
            }

            if (meetups.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text("No upcoming meetups hosted yet.", style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            final meetupData = meetups[index - 1];
            return _buildMeetupCard(context, meetupData);
          },
        );
      },
    );
  }

  // ================= Live Meetup Details Bottom Sheet =================
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
                            meetup['image'] ?? 'https://via.placeholder.com/600',
                            height: 220, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(height: 220, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(meetup['title'] ?? 'Title', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF115C49).withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.calendar_month, color: Color(0xFF115C49), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meetup['date'] ?? 'TBA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                                Text(meetup['time'] ?? 'TBA', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF115C49).withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.location_on, color: Color(0xFF115C49), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(meetup['location'] ?? 'Location TBA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 24, backgroundColor: Colors.grey.shade200, backgroundImage: NetworkImage(meetup['host_image'] ?? ''), onBackgroundImageError: (e,s){}),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Hosted by", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(meetup['host_name'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                              ],
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF115C49)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text('Follow', style: TextStyle(color: Color(0xFF115C49), fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("About this meetup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          meetup['description'] ?? 'No description provided.',
                          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF115C49),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Join Meetup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ================= Helper Widgets =================

  Widget _buildMeetupCard(BuildContext context, dynamic meetup) {
    String rawDate = meetup['date'] ?? 'TBA';
    String datePart1 = rawDate.split(' ').isNotEmpty ? rawDate.split(' ')[0] : '';
    String datePart2 = rawDate.split(' ').length > 1 ? rawDate.split(' ')[1].replaceAll(',', '') : '';

    return GestureDetector(
      onTap: () => _showMeetupDetailsSheet(context, meetup),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                meetup['image'] ?? 'https://via.placeholder.com/600',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF115C49).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Text(datePart1, style: const TextStyle(color: Color(0xFF115C49), fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(datePart2, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meetup['title'] ?? 'Title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(child: Text(meetup['location'] ?? 'Location TBA', style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade200, backgroundImage: NetworkImage(meetup['host_image'] ?? ''), onBackgroundImageError: (e,s){}),
                          const SizedBox(width: 8),
                          Text("By ${meetup['host_name'] ?? 'Admin'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                        child: Text("${meetup['joined'] ?? '0'} Joined", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      )
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

  Widget _buildGuideCard({required String title, required String subtitle, required String image}) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(image, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image, color: Colors.grey))))),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)]))
        ],
      ),
    );
  }

  Widget _buildCollectionCard({required String title, required String image, required String placesCount}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      height: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(image, width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.7)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
          Positioned(bottom: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: Text(placesCount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))]))
        ],
      ),
    );
  }

  Widget _buildReviewCard({required String userName, required String userImage, required String placeName, required String time, required int rating, required String review}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade200, backgroundImage: NetworkImage(userImage), onBackgroundImageError: (e, s) {}),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)), Text("Reviewed $placeName • $time", style: TextStyle(color: Colors.grey.shade500, fontSize: 11))])),
              const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: List.generate(5, (index) => Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
          const SizedBox(height: 8),
          Text(review, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey.shade600), const SizedBox(width: 6), Text("Helpful", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)), const SizedBox(width: 16), Icon(Icons.share_outlined, size: 16, color: Colors.grey.shade600)])
        ],
      ),
    );
  }
}