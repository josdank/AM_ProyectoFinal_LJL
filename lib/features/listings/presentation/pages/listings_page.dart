import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/listing_card_widget.dart';
import '../widgets/price_filter_widget.dart';
import 'listing_detail_page.dart';

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
    return Scaffold(
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

          // Chips de filtros activos
          if (_minPrice != null ||
              _maxPrice != null ||
              _selectedRoomType != null ||
              _petsAllowed != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_minPrice != null || _maxPrice != null)
                    Chip(
                      label: Text(
                        'Precio: \$${_minPrice?.toInt() ?? 0} - \$${_maxPrice?.toInt() ?? 'Sin límite'}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                        });
                        _applyFilters();
                      },
                    ),
                  if (_selectedRoomType != null)
                    Chip(
                      label: Text(_selectedRoomType == 'private'
                          ? 'Privada'
                          : 'Compartida'),
                      onDeleted: () {
                        setState(() {
                          _selectedRoomType = null;
                        });
                        _applyFilters();
                      },
                    ),
                  if (_petsAllowed != null)
                    Chip(
                      label: const Text('Mascotas permitidas'),
                      onDeleted: () {
                        setState(() {
                          _petsAllowed = null;
                        });
                        _applyFilters();
                      },
                    ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar filtros'),
                  ),
                ],
              ),
            ),

          // Lista de publicaciones
          Expanded(
            child: BlocBuilder<ListingBloc, ListingState>(
              builder: (context, state) {
                if (state is ListingLoading || state is ListingSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ListingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ListingBloc>()
                                .add(const ListingsLoadRequested());
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
                        Icon(Icons.home_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron habitaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ListingBloc>()
                        .add(const ListingsLoadRequested());
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
            ),
          ),
        ],
      ),
    );
  }
}

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
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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