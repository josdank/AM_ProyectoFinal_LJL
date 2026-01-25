import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/location_model.dart';
import '../models/place_model.dart';

abstract class LocationDatasource {
  Future<LocationModel> getCurrentLocation();
  Future<bool> requestPermission();
  Future<bool> checkPermission();
  Stream<LocationModel> getLocationStream();
  Future<List<PlaceModel>> getUserPlaces(String userId);
  Future<PlaceModel> savePlace(PlaceModel place);
  Future<void> deletePlace(String placeId);
  Future<List<PlaceModel>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String? type,
  });
}

class LocationDatasourceImpl implements LocationDatasource {
  final SupabaseClient client;

  LocationDatasourceImpl({required this.client});

  @override
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      throw ServerException(message: 'Error al verificar permisos: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      throw ServerException(message: 'Error al solicitar permisos: $e');
    }
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      // Verificar si el servicio está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const ServerException(
          message: 'Los servicios de ubicación están deshabilitados',
        );
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error al obtener ubicación: $e');
    }
  }

  @override
  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map(
      (position) => LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  @override
  Future<List<PlaceModel>> getUserPlaces(String userId) async {
    try {
      final response = await client
          .from('user_places')
          .select()
          .match({'user_id': userId})
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PlaceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al cargar lugares: $e');
    }
  }

  @override
  Future<PlaceModel> savePlace(PlaceModel place) async {
    try {
      final data = place.toJson();
      data.remove('id');
      data.remove('created_at');

      final response = await client
          .from('user_places')
          .insert(data)
          .select()
          .single();

      return PlaceModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al guardar lugar: $e');
    }
  }

  @override
  Future<void> deletePlace(String placeId) async {
    try {
      await client.from('user_places').delete().match({'id': placeId});
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar lugar: $e');
    }
  }

  @override
  Future<List<PlaceModel>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String? type,
  }) async {
    try {
      final response = type != null
          ? await client
                .from('public_places')
                .select()
                .filter('type', 'eq', type)
                .order('name', ascending: true)
          : await client
                .from('public_places')
                .select()
                .order('name', ascending: true);

      final places = (response as List)
          .map((json) => PlaceModel.fromJson(json as Map<String, dynamic>))
          .where((place) {
            final distance = _calculateDistance(
              latitude,
              longitude,
              place.latitude,
              place.longitude,
            );
            return distance <= radiusMeters;
          })
          .toList();

      return places;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al buscar lugares: $e');
    }
  }

  // Cálculo de distancia (Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // metros
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    if (x < 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  double _atan(double x) => x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
}
