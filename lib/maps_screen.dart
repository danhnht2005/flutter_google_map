import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {}; // Danh sách marker
  final Set<Polyline> _polylines = {}; // Danh sách polyline
  static final LatLng _destination = LatLng(
    10.7769,
    106.7009,
  ); // Vị trí mặc định TP.HCM
  final CameraPosition _initialPosition = CameraPosition(
    target: _destination,
    zoom: 14,
  );
  LatLng? _start; // Biến lưu vị trí hiện tại của người dùng
  LatLng? _end; // Biến lưu vị trí điểm đến

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Hàm thêm marker
  void _addMarker(LatLng position, String markerId) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: markerId),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Marker: $markerId\nVĩ độ: ${position.latitude}\nKinh độ: ${position.longitude}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          draggable: true, // Bắt buộc phải có thuộc tính này để cho phép kéo thả
        onDragEnd: (LatLng newPosition) {
          // 1. Cập nhật state để xóa marker ở vị trí cũ
          setState(() {
            _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
          });
          
          // 2. Gọi lại hàm để vẽ lại marker với tọa độ mới (newPosition)
          _addMarker(newPosition, markerId);

        },
        ),
      );
    });
  }

  // Hàm di chuyển camera đến vị trí chỉ định mới
  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng bật dịch vụ vị trí!')));
      return;
    }
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _start = LatLng(position.latitude, position.longitude);
      _addMarker(_start!, "Vị trí của bạn");
      _moveCamera(_start!);
    });
  }

  // Tìm đường đi
  Future<void> _findRoute() async {
    if (_start == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chưa lấy được vị trí hiện tại!')));
      return;
    }
    if (_end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhấn giữ bản đồ để chọn điểm đến!')),
      );
      return;
    }

    final url =
        'https://router.project-osrm.org/route/v1/driving/${_start!.longitude},${_start!.latitude};${_end!.longitude},${_end!.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    debugPrint('OSRM Response status: ${response.statusCode}');
    debugPrint('OSRM Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final apiCode = data['code']?.toString() ?? 'Unknown';

      if (apiCode == 'Ok' &&
          data['routes'] != null &&
          (data['routes'] as List).isNotEmpty) {
        final List<LatLng> points = _parseOsrmGeometry(
          data['routes'][0]['geometry']['coordinates'],
        );

        if (points.isEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không đọc được dữ liệu tuyến đường từ OSRM.'),
            ),
          );
          return;
        }

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
        _moveCamera(_start!);
      } else {
        final message =
            data['message']?.toString() ?? 'Không tìm thấy tuyến đường.';
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gọi API: ${response.statusCode}')),
      );
    }
  }

  List<LatLng> _parseOsrmGeometry(dynamic coordinates) {
    if (coordinates is! List) return [];

    final points = <LatLng>[];
    for (final item in coordinates) {
      if (item is List && item.length >= 2) {
        final lng = (item[0] as num?)?.toDouble();
        final lat = (item[1] as num?)?.toDouble();
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Maps Flutter Demo')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onLongPress: (LatLng position) {
              _addMarker(position, "Điểm đến");
              _end = position;
            },
            polylines: _polylines,
          ),

          Positioned(
            bottom: 95,
            right: 7,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(Icons.directions, color: Colors.blue),
              onPressed: () {
                _findRoute();
              },
            ),
          ),
        ],
      ),
    );
  }
}
