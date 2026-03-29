import 'package:flutter/material.dart';
import '../services/map_api_service.dart';

class MapSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Tìm kiếm ở đây';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.black87),
          onPressed: () {
            query = '';
          },
        ),
      IconButton(
        icon: const Icon(Icons.mic, color: Colors.black87),
        onPressed: () {},
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.microtask(() => close(context, query));
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      return FutureBuilder<List<Map<String, String>>>(
        future: MapApiService.getSearchSuggestions(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không tìm thấy kết quả phù hợp."));
          }
          final results = snapshot.data!;
          return Container(
            color: Colors.white,
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.black54),
                  title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: item['subtitle']!.isNotEmpty
                      ? Text(item['subtitle']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54))
                      : null,
                  onTap: () {
                    query = item['query'] ?? item['title']!;
                    close(context, query);
                  },
                );
              },
            ),
          );
        },
      );
    }

    final List<Map<String, String>> recentSearches = [
      {
        "title": "Đại học Công Thương TP.HCM",
        "subtitle": "140 Lê Trọng Tấn, Tây Thạnh, Tân Phú, Hồ Chí Minh",
        "isVenue": "true",
        "query": "Đại học Công Thương, Tân Phú",
      },
      {
        "title": "Aeon Mall Tân Phú Celadon",
        "subtitle": "30 Bờ Bao Tân Thắng, Sơn Kỳ, Tân Phú\nĐang mở cửa",
        "isVenue": "true",
        "query": "Aeon Mall Tân Phú",
      },
      {
        "title": "Chợ Bến Thành",
        "subtitle": "Đường Lê Lợi, Phường Bến Thành, Quận 1, Hồ Chí Minh",
        "query": "Chợ Bến Thành",
      },
      {
        "title": "Landmark 81",
        "subtitle": "720A Điện Biên Phủ, Phường 22, Bình Thạnh, Hồ Chí Minh",
        "query": "Landmark 81",
      },
      {
        "title": "Bến xe Miền Đông mới",
        "subtitle": "501 Hoàng Hữu Nam, Long Bình, Thủ Đức, Hồ Chí Minh",
        "query": "Bến xe Miền Đông Mới",
      },
    ];

    return Container(
      color: const Color(0xFFF1F3F4),
      child: ListView(
        children: [
          // Da xoa block nay vi da su dung tinh nang autocomplete o FutureBuilder tren
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.home_outlined, "Nhà riêng", subtitle: "Ghim đã thả"),
                _buildQuickAction(Icons.work_outline, "Nơi làm việc", subtitle: "Ghim đã thả"),
                _buildQuickAction(Icons.more_horiz, "Xem thêm"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Gần đây",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Icon(Icons.info_outline, size: 18, color: Colors.black54),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: recentSearches.map((item) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8EAED),
                    child: Icon(Icons.access_time, color: Colors.black54, size: 20),
                  ),
                  title: Text(
                    item["title"]!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: item["subtitle"]!.isNotEmpty
                      ? Text(
                          item["subtitle"]!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: item.containsKey("isVenue")
                                ? Colors.green[700]
                                : Colors.black54,
                            fontSize: 13,
                          ),
                        )
                      : null,
                  onTap: () {
                    query = item["query"] ?? item["title"]!;
                    close(context, query);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, {String? subtitle}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE8EAED),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ],
    );
  }
}
