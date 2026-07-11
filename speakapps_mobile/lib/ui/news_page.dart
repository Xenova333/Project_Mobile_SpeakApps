import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'news_detail_page.dart';
import 'add_event_page.dart';
import 'widgets/custom_bottom_nav.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final EventController eventController = Get.put(EventController());
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
    eventController.loadEvents();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    setState(() => _userRole = role);
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = const Color(0xFFF6A039);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1128) : null,
                    gradient: isDark ? null : LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        primaryOrange.withOpacity(0.8),
                        primaryOrange.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Berita dan Informasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111C44) : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: isDark ? null : Border.all(color: primaryOrange, width: 1.0),
                    ),
                    child: TextField(
                      onChanged: (val) => eventController.searchEvent(val),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Cari event...',
                        hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black38),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: primaryOrange, size: 20),
                      ),
                    ),
                  ),
                ),

                // Event List
                Expanded(
                  child: Obx(() {
                    if (eventController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final displayEvents = eventController.filteredEvents;

                    if (displayEvents.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Belum ada event tersedia.',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => eventController.loadEvents(),
                      color: primaryOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 100),
                        itemCount: displayEvents.length,
                        itemBuilder: (context, index) {
                          final event = displayEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailPage(
                                      event: event,
                                    ),
                                  ),
                                );
                              },
                              child: _buildEventCard(event, primaryOrange, isDark),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),

            // Bottom Navigation Bar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, Color primaryColor, bool isDark) {
    final imageUrl = ApiConfig.eventImage(event.image);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C44) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[200],
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('IMAGE ERROR: url=$imageUrl, error=$error');
                        return const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.event, color: Colors.grey, size: 50),
                    ),
            ),
          ),

          // Text info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (event.eventDate != null && event.eventDate!.isNotEmpty)
                  Text(
                    event.eventDate!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
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
