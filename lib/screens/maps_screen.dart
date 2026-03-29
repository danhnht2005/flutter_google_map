import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../services/map_api_service.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/map_action_buttons.dart';
import '../widgets/place_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  static const LatLng _destination = LatLng(10.7769, 106.7009);
  
  final CameraPosition _initialPosition = const CameraPosition(
    target: _destination,
    zoom: 14,
  );
  
  LatLng? _start;
  LatLng? _end;
  int _selectedIndex = 0;
  String _searchQueryText = "Tìm kiếm ở đây";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _addMarker(LatLng position, String markerId) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: markerId),
        ),
      );
    });
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí!')),
        );
      }
      return;
    }
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _start = LatLng(position.latitude, position.longitude);
      _addMarker(_start!, "Vị trí của bạn");
    });
    _moveCamera(_start!);
  }

  Future<void> _findRoute() async {
    if (_start == null || _end == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn điểm đến!')),
        );
      }
      return;
    }

    final points = await MapApiService.getRoute(_start!, _end!);

    if (points != null && points.isNotEmpty) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: const Color(0xFF007A7C),
            width: 6,
          ),
        );
      });
      _moveCamera(_start!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm được tuyến đường.')),
        );
      }
    }
  }

  Future<void> _handleSearchPlace(String query) async {
    setState(() {
      _searchQueryText = query;
    });

    final placeData = await MapApiService.searchPlace(query);

    if (placeData != null) {
      final lat = double.parse(placeData['lat']);
      final lon = double.parse(placeData['lon']);
      final displayName = placeData['display_name'];

      setState(() {
        _end = LatLng(lat, lon);
        _addMarker(_end!, query);
      });
      await _moveCamera(_end!);

      if (mounted) {
        PlaceBottomSheet.show(
          context: context,
          title: query,
          fullAddress: displayName,
          onDirectionTap: () {
            Navigator.pop(context);
            _findRoute(); 
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy địa điểm!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onLongPress: (LatLng position) {
              _addMarker(position, "Điểm đến");
              _end = position;
            },
          ),
          MapSearchBar(
            queryText: _searchQueryText,
            onSearchResult: _handleSearchPlace,
          ),
          MapActionButtons(
            onMyLocationTap: () {
              if (_start != null) _moveCamera(_start!);
            },
            onDirectionTap: _findRoute,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Khám phá"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: "Đã lưu"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Đóng góp"),
        ],
      ),
    );
  }
}
