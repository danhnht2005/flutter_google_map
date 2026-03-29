import 'package:flutter/material.dart';

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
    final List<Map<String, String>> recentSearches = [
      {
        "title": "MB Phú Nhuận",
        "subtitle": "Tòa nhà Prince Residence, 19 - 21 Đ. Nguyễn...",
      },
      {
        "title": "mbbank gần đây",
        "subtitle": "",
      },
      {
        "title": "148/9 Lý Chính Thắng",
        "subtitle": "Võ Thị Sáu, Xuân Hòa, Hồ Chí Minh",
      },
      {
        "title": "Chung cư K26",
        "subtitle": "phường 5, Hạnh Thông, Hồ Chí Minh",
      },
      {
        "title": "MANGROVE COFFEE & TEA",
        "subtitle": "Đường Cao Thắng, Phường 12, Quận 10\nĐang mở cửa",
        "isVenue": "true",
      },
    ];

    return Container(
      color: const Color(0xFFF1F3F4),
      child: ListView(
        children: [
          if (query.isNotEmpty)
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.search, color: Colors.white, size: 20),
                ),
                title: Text(
                  'Tìm tại: "$query"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  close(context, query);
                },
              ),
            ),
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
                    query = item["title"]!;
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
