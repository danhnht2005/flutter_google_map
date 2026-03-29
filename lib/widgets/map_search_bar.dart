import 'package:flutter/material.dart';
import '../screens/search_delegate.dart';

class MapSearchBar extends StatelessWidget {
  final String queryText;
  final Function(String result) onSearchResult;

  const MapSearchBar({
    super.key,
    required this.queryText,
    required this.onSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Google_Maps_icon_%282020%29.svg/512px-Google_Maps_icon_%282020%29.svg.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.location_on, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      final result = await showSearch(
                        context: context,
                        delegate: MapSearchDelegate(),
                      );

                      if (result != null && result.isNotEmpty) {
                        onSearchResult(result);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: queryText.isEmpty ? "Tìm kiếm ở đây" : queryText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                const Icon(Icons.mic, color: Colors.black87),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(Icons.home, "Nhà riêng"),
                _buildFilterChip(Icons.restaurant, "Nhà hàng"),
                _buildFilterChip(Icons.shopping_bag, "Mua sắm"),
                _buildFilterChip(Icons.local_cafe, "Quán cà phê"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
