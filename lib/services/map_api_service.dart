import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapApiService {
  static Future<List<LatLng>?> getRoute(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return await compute(_processOsrmResponse, response.body);
      }
    } catch (e) {
      debugPrint("OSRM Error: $e");
    }
    return null;
  }

  static List<LatLng>? _processOsrmResponse(String responseBody) {
    try {
      final Map<String, dynamic> data = jsonDecode(responseBody);
      if (data['code']?.toString() == 'Ok' &&
          data['routes'] != null &&
          (data['routes'] as List).isNotEmpty) {
        final coordinates = data['routes'][0]['geometry']['coordinates'];
        
        if (coordinates is! List) return [];
        final points = <LatLng>[];
        for (final item in coordinates) {
          if (item is List && item.length >= 2) {
            final lng = (item[0] as num?)?.toDouble();
            final lat = (item[1] as num?)?.toDouble();
            if (lat != null && lng != null) points.add(LatLng(lat, lng));
          }
        }
        return points;
      }
    } catch (e) {
      debugPrint("Isolate parse error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> searchPlace(String query) async {
    if (query.isEmpty) return null;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'FlutterMapDemo_SinhVien'});
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint("Nominatim Error: $e");
    }
    return null;
  }
}
