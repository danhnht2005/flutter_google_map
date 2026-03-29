import 'package:flutter/material.dart';

class PlaceBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    required String fullAddress,
    required VoidCallback onDirectionTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.2,
          maxChildSize: 0.85,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text("4,0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 4),
                      Row(
                        children: List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                      ),
                      const Icon(Icons.star_border, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text("(163)", style: TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(width: 8),
                      const Text("• Khu vực", style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionBtn(
                          icon: Icons.directions,
                          label: "Đường đi",
                          isPrimary: true,
                          onTap: onDirectionTap,
                        ),
                        const SizedBox(width: 8),
                        _buildActionBtn(icon: Icons.play_arrow, label: "Bắt đầu", onTap: () {}),
                        const SizedBox(width: 8),
                        _buildActionBtn(icon: Icons.phone, label: "Gọi", onTap: () {}),
                        const SizedBox(width: 8),
                        _buildActionBtn(icon: Icons.bookmark_border, label: "Lưu", onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12, thickness: 1),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                    title: Text(fullAddress, style: const TextStyle(fontSize: 14)),
                  ),
                  
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: Colors.black54),
                    title: Text("Đang mở cửa • Đóng cửa lúc 22:00", style: TextStyle(fontSize: 14, color: Colors.green)),
                    trailing: Icon(Icons.keyboard_arrow_down),
                  ),
                  
                  const SizedBox(height: 12),
                  const Text("Ảnh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildMockImage('https://images.unsplash.com/photo-1542204165-65bf26472b9b?q=80&w=2674&auto=format&fit=crop'),
                        const SizedBox(width: 8),
                        _buildMockImage('https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2647&auto=format&fit=crop'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildActionBtn({required IconData icon, required String label, bool isPrimary = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF007A7C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : const Color(0xFF007A7C)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMockImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(width: 150, height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
      ),
    );
  }
}
