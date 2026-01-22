import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/amenities_selector_widget.dart';

class CreateListingPage extends StatefulWidget {
  final String userId;
  final Listing? editingListing;

  const CreateListingPage({
    super.key,
    required this.userId,
    this.editingListing,
  });

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _roomType = 'private';
  String _leaseDuration = 'monthly';
  int _bathroomsCount = 1;
  int _maxOccupants = 1;
  DateTime? _availableFrom;

  bool _utilitiesIncluded = false;
  bool _wifiIncluded = false;
  bool _parkingIncluded = false;
  bool _furnished = false;
  bool _petsAllowed = false;
  bool _smokingAllowed = false;
  bool _guestsAllowed = true;

  List<String> _selectedAmenities = [];
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.editingListing != null) {
      _loadExistingListing(widget.editingListing!);
    }
  }

  void _loadExistingListing(Listing listing) {
    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _priceController.text = listing.price.toString();
    _addressController.text = listing.address;
    _cityController.text = listing.city;
    _stateController.text = listing.state;
    _roomType = listing.roomType;
    _leaseDuration = listing.leaseDuration;
    _bathroomsCount = listing.bathroomsCount;
    _maxOccupants = listing.maxOccupants;
    _availableFrom = listing.availableFrom;
    _utilitiesIncluded = listing.utilitiesIncluded;
    _wifiIncluded = listing.wifiIncluded;
    _parkingIncluded = listing.parkingIncluded;
    _furnished = listing.furnished;
    _petsAllowed = listing.petsAllowed;
    _smokingAllowed = listing.smokingAllowed;
    _guestsAllowed = listing.guestsAllowed;
    _selectedAmenities = List.from(listing.amenities);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _availableFrom = picked;
      });
    }
  }

  void _saveListing() {
    if (_formKey.currentState!.validate()) {
      final listing = Listing(
        id: widget.editingListing?.id ?? const Uuid().v4(),
        ownerId: widget.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        roomType: _roomType,
        leaseDuration: _leaseDuration,
        bathroomsCount: _bathroomsCount,
        maxOccupants: _maxOccupants,
        availableFrom: _availableFrom,
        utilitiesIncluded: _utilitiesIncluded,
        wifiIncluded: _wifiIncluded,
        parkingIncluded: _parkingIncluded,
        furnished: _furnished,
        amenities: _selectedAmenities,
        petsAllowed: _petsAllowed,
        smokingAllowed: _smokingAllowed,
        guestsAllowed: _guestsAllowed,
        createdAt: widget.editingListing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.editingListing != null) {
        context.read<ListingBloc>().add(ListingUpdateRequested(listing: listing));
      } else {
        context.read<ListingBloc>().add(ListingCreateRequested(listing: listing));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingListing != null
            ? 'Editar Publicación'
            : 'Nueva Publicación'),
        actions: [
          TextButton(
            onPressed: _saveListing,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: BlocConsumer<ListingBloc, ListingState>(
        listener: (context, state) {
          if (state is ListingCreated || state is ListingUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Publicación guardada')),
            );
            Navigator.pop(context);
          } else if (state is ListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ListingCreating || state is ListingUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imágenes
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // Información básica
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),

                  // Ubicación
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // Detalles
                  _buildDetailsSection(),
                  const SizedBox(height: 24),

                  // Servicios incluidos
                  _buildServicesSection(),
                  const SizedBox(height: 24),

                  // Amenidades
                  AmenitiesSelectorWidget(
                    selectedAmenities: _selectedAmenities,
                    onChanged: (amenities) {
                      setState(() => _selectedAmenities = amenities);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Reglas
                  _buildRulesSection(),
                  const SizedBox(height: 24),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _saveListing,
                      child: Text(widget.editingListing != null
                          ? 'Actualizar Publicación'
                          : 'Crear Publicación'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(_selectedImages[index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _selectedImages.removeAt(index));
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Agregar Fotos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información Básica',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Habitación acogedora en el centro',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Describe tu habitación...',
              ),
              maxLines: 4,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Precio mensual (USD) *',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Campo requerido';
                if (double.tryParse(value!) == null) return 'Precio inválido';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubicación', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección *'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Ciudad *'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(labelText: 'Provincia *'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _roomType,
              decoration: const InputDecoration(labelText: 'Tipo de habitación'),
              items: const [
                DropdownMenuItem(value: 'private', child: Text('Privada')),
                DropdownMenuItem(value: 'shared', child: Text('Compartida')),
              ],
              onChanged: (value) => setState(() => _roomType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _leaseDuration,
              decoration: const InputDecoration(labelText: 'Duración del contrato'),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                DropdownMenuItem(value: 'quarterly', child: Text('Trimestral')),
                DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                DropdownMenuItem(value: 'flexible', child: Text('Flexible')),
              ],
              onChanged: (value) => setState(() => _leaseDuration = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _bathroomsCount,
                    decoration: const InputDecoration(labelText: 'Baños'),
                    items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _bathroomsCount = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _maxOccupants,
                    decoration: const InputDecoration(labelText: 'Ocupantes'),
                    items: List.generate(
                      6,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _maxOccupants = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Disponible desde'),
                child: Text(
                  _availableFrom != null
                      ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                      : 'Seleccionar fecha',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicios Incluidos',
                style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              title: const Text('Servicios incluidos'),
              value: _utilitiesIncluded,
              onChanged: (value) => setState(() => _utilitiesIncluded = value),
            ),
            SwitchListTile(
              title: const Text('WiFi incluido'),
              value: _wifiIncluded,
              onChanged: (value) => setState(() => _wifiIncluded = value),
            ),
            SwitchListTile(
              title: const Text('Estacionamiento'),
              value: _parkingIncluded,
              onChanged: (value) => setState(() => _parkingIncluded = value),
            ),
            SwitchListTile(
              title: const Text('Amueblado'),
              value: _furnished,
              onChanged: (value) => setState(() => _furnished = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reglas', style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              title: const Text('Mascotas permitidas'),
              value: _petsAllowed,
              onChanged: (value) => setState(() => _petsAllowed = value),
            ),
            SwitchListTile(
              title: const Text('Fumar permitido'),
              value: _smokingAllowed,
              onChanged: (value) => setState(() => _smokingAllowed = value),
            ),
            SwitchListTile(
              title: const Text('Invitados permitidos'),
              value: _guestsAllowed,
              onChanged: (value) => setState(() => _guestsAllowed = value),
            ),
          ],
        ),
      ),
    );
  }
}