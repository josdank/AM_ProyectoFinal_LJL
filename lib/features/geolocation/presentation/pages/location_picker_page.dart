import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/location_point.dart';
import '../bloc/map_bloc.dart';

class LocationPickerPage extends StatefulWidget {
  final LocationPoint? initialLocation;

  const LocationPickerPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late MapController _mapController;
  LocationPoint? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar Ubicación'),
          actions: [
            TextButton(
              onPressed: _selectedLocation != null
                  ? () => Navigator.pop(context, _selectedLocation)
                  : null,
              child: const Text('Confirmar'),
            ),
          ],
        ),
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MapError) {
              return Center(child: Text(state.message));
            }

            if (state is! MapLoaded) {
              return const SizedBox.shrink();
            }

            final initialCenter = _selectedLocation ?? state.userLocation;

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      initialCenter.latitude,
                      initialCenter.longitude,
                    ),
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = LocationPoint(
                          latitude: point.latitude,
                          longitude: point.longitude,
                        );
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.busca_companero',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _selectedLocation!.latitude,
                              _selectedLocation!.longitude,
                            ),
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Toca en el mapa para seleccionar una ubicación',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'my_location',
                    onPressed: () {
                      _mapController.move(
                        LatLng(
                          state.userLocation.latitude,
                          state.userLocation.longitude,
                        ),
                        15.0,
                      );
                      setState(() {
                        _selectedLocation = state.userLocation;
                      });
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}