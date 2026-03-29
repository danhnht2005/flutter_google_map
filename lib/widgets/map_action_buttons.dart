import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onMyLocationTap;
  final VoidCallback onDirectionTap;

  const MapActionButtons({
    super.key,
    required this.onMyLocationTap,
    required this.onDirectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "btnLocation",
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                onPressed: onMyLocationTap,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "btnDirection",
                backgroundColor: const Color(0xFF007A7C),
                foregroundColor: Colors.white,
                onPressed: onDirectionTap,
                child: const Icon(Icons.directions, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
