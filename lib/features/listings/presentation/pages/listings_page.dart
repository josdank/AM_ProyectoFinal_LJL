import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/listing_card_widget.dart';
import '../widgets/price_filter_widget.dart';
import 'listing_detail_page.dart';

import '../../../user_properties/presentation/bloc/user_property_bloc.dart';
import '../../../user_properties/domain/entities/user_property.dart';
import '../../../user_properties/domain/usecases/search_nearby_user_properties.dart';
import '../../../geolocation/domain/entities/location_point.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  final _searchController = TextEditingController();
  double? _minPrice;
  double? _maxPrice;
  String? _selectedRoomType;
  bool? _petsAllowed;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final city = _searchController.text.trim().isEmpty
        ? null
        : _searchController.text.trim();

    context.read<ListingBloc>().add(
          ListingsSearchRequested(
            city: city,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            roomType: _selectedRoomType,
            petsAllowed: _petsAllowed,
          ),
        );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _minPrice = null;
      _maxPrice = null;
      _selectedRoomType = null;
      _petsAllowed = null;
    });
    context.read<ListingBloc>().add(const ListingsLoadRequested());
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialRoomType: _selectedRoomType,
        initialPetsAllowed: _petsAllowed,
        onApply: (minPrice, maxPrice, roomType, petsAllowed) {
          setState(() {
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _selectedRoomType = roomType;
            _petsAllowed = petsAllowed;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // NUEVO: Agregar UserPropertyBloc
        BlocProvider(
          create: (_) => sl<UserPropertyBloc>()
            ..add(UserPropertySearchNearbyRequested(
              center: const LocationPoint(
                latitude: -0.3089, 
                longitude: -78.5500,
              ),
              radiusMeters: 50000, // 50km para mostrar todas
            )),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habitaciones Disponibles'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por ciudad...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _clearFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),

            // NUEVO: Tabs para Listings vs User Properties
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Propiedades de Usuarios', icon: Icon(Icons.home)),
                        Tab(text: 'Listings Oficiales', icon: Icon(Icons.business)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: User Properties
                          _buildUserPropertiesTab(),
                          
                          // Tab 2: Listings Oficiales
                          _buildListingsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Tab de User Properties
  Widget _buildUserPropertiesTab() {
    return BlocBuilder<UserPropertyBloc, UserPropertyState>(
      builder: (context, state) {
        if (state is UserPropertySearching || state is UserPropertyLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserPropertyError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserPropertyBloc>().add(
                      UserPropertySearchNearbyRequested(
                        center: const LocationPoint(
                          latitude: -0.3089,
                          longitude: -78.5500,
                        ),
                        radiusMeters: 50000,
                      ),
                    );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        List<UserProperty> properties = [];
        if (state is UserPropertySearchResults) {
          properties = state.properties;
        }

        if (properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron propiedades de usuarios',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<UserPropertyBloc>().add(
              UserPropertySearchNearbyRequested(
                center: const LocationPoint(
                  latitude: -0.3089,
                  longitude: -78.5500,
                ),
                radiusMeters: 50000,
              ),
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _UserPropertyCard(property: property);
            },
          ),
        );
      },
    );
  }

  // Tab de Listings Oficiales (existente)
  Widget _buildListingsTab() {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingLoading || state is ListingSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ListingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ListingBloc>().add(const ListingsLoadRequested());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final listings = state is ListingsLoaded
            ? state.listings
            : state is ListingsSearchResults
                ? state.listings
                : <Listing>[];

        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron listings',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ListingBloc>().add(const ListingsLoadRequested());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return ListingCardWidget(
                listing: listings[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailPage(
                        listing: listings[index],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

// NUEVO: Widget para mostrar User Properties como cards
class _UserPropertyCard extends StatelessWidget {
  final UserProperty property;

  const _UserPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Stack(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: property.imageUrls.isNotEmpty
                    ? Image.network(
                        property.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.home, size: 60),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 60),
                      ),
              ),
              // Badge de "Propiedad de Usuario"
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Usuario Verificado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Información
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Precio
                Text(
                  '\$${property.price.toStringAsFixed(0)}/${property.pricePeriod == "monthly" ? "mes" : "día"}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),

                // Título
                Text(
                  property.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Ubicación
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.city}, ${property.state}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Detalles
                Row(
                  children: [
                    _buildQuickDetail(Icons.bed, '${property.bedrooms}'),
                    const SizedBox(width: 16),
                    _buildQuickDetail(Icons.bathtub, '${property.bathrooms}'),
                    const SizedBox(width: 16),
                    _buildQuickDetail(Icons.people, '${property.maxOccupants}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Filter Bottom Sheet (sin cambios)
class _FilterBottomSheet extends StatefulWidget {
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialRoomType;
  final bool? initialPetsAllowed;
  final Function(double?, double?, String?, bool?) onApply;

  const _FilterBottomSheet({
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialRoomType,
    this.initialPetsAllowed,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double? _minPrice;
  late double? _maxPrice;
  late String? _roomType;
  late bool? _petsAllowed;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _roomType = widget.initialRoomType;
    _petsAllowed = widget.initialPetsAllowed;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),

            PriceFilterWidget(
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              onMinPriceChanged: (value) => setState(() => _minPrice = value),
              onMaxPriceChanged: (value) => setState(() => _maxPrice = value),
            ),

            const SizedBox(height: 16),

            Text('Tipo de habitación',
                style: Theme.of(context).textTheme.titleMedium),
            RadioListTile<String?>(
              title: const Text('Todas'),
              value: null,
              groupValue: _roomType,
              onChanged: (value) => setState(() => _roomType = value),
            ),
            RadioListTile<String?>(
              title: const Text('Privada'),
              value: 'private',
              groupValue: _roomType,
              onChanged: (value) => setState(() => _roomType = value),
            ),
            RadioListTile<String?>(
              title: const Text('Compartida'),
              value: 'shared',
              groupValue: _roomType,
              onChanged: (value) => setState(() => _roomType = value),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Mascotas permitidas'),
              value: _petsAllowed ?? false,
              onChanged: (value) =>
                  setState(() => _petsAllowed = value ? true : null),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                widget.onApply(_minPrice, _maxPrice, _roomType, _petsAllowed);
                Navigator.pop(context);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}