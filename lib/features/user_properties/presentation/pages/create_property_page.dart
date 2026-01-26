import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/ljl_colors.dart';
import '../../../geolocation/domain/entities/location_point.dart';
import '../../../geolocation/presentation/pages/location_picker_page.dart';
import '../../domain/entities/user_property.dart';
import '../bloc/user_property_bloc.dart';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  State<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaSqmController = TextEditingController();
  final _floorNumberController = TextEditingController();

  String _propertyType = 'apartment';
  int _bedrooms = 1;
  int _bathrooms = 1;
  int _maxOccupants = 1;
  int _minStayMonths = 1;
  String _pricePeriod = 'monthly';

  bool _utilitiesIncluded = false;
  bool _wifiIncluded = false;
  bool _parkingIncluded = false;
  bool _furnished = false;
  bool _petsAllowed = false;
  bool _smokingAllowed = false;
  bool _guestsAllowed = true;

  LocationPoint? _selectedLocation;
  List<String> _selectedImagePaths = [];
  List<String> _selectedAmenities = [];

  final List<String> _availableAmenities = [
    'Aire Acondicionado',
    'Calefacción',
    'Lavadora',
    'Secadora',
    'Cocina Equipada',
    'Microondas',
    'Refrigerador',
    'TV',
    'Balcón',
    'Terraza',
    'Jardín',
    'Piscina',
    'Gimnasio',
    'Ascensor',
    'Portero',
    'Seguridad 24/7',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _priceController.dispose();
    _areaSqmController.dispose();
    _floorNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserPropertyBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Propiedad'),
        ),
        body: BlocConsumer<UserPropertyBloc, UserPropertyState>(
          listener: (context, state) {
            if (state is UserPropertyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is UserPropertyCreated) {
              // Subir imágenes si hay
              if (_selectedImagePaths.isNotEmpty) {
                final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                context.read<UserPropertyBloc>().add(
                      UserPropertyUploadImagesRequested(
                        propertyId: state.property.id,
                        ownerId: userId,
                        imagePaths: _selectedImagePaths,
                      ),
                    );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Propiedad creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
            }

            if (state is UserPropertyImagesUploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Propiedad e imágenes guardadas exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            final isLoading = state is UserPropertyCreating ||
                state is UserPropertyUploadingImages;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Título
                  _buildSectionTitle('Información Básica'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la Propiedad *',
                      hintText: 'Ej: Apartamento céntrico 2 habitaciones',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Tipo de Propiedad
                  DropdownButtonFormField<String>(
                    value: _propertyType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Propiedad *',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'apartment', child: Text('🏢 Apartamento')),
                      DropdownMenuItem(value: 'house', child: Text('🏠 Casa')),
                      DropdownMenuItem(value: 'room', child: Text('🚪 Habitación')),
                      DropdownMenuItem(value: 'studio', child: Text('🛋️ Studio')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) => setState(() => _propertyType = value!),
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      hintText: 'Describe tu propiedad...',
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Ubicación
                  _buildSectionTitle('Ubicación'),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: LjlColors.teal),
                    title: Text(
                      _selectedLocation != null
                          ? 'Ubicación seleccionada'
                          : 'Seleccionar ubicación en el mapa *',
                    ),
                    subtitle: _selectedLocation != null
                        ? Text(
                            'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          )
                        : const Text('Toca para abrir el mapa'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: isLoading ? null : _pickLocation,
                    tileColor: _selectedLocation != null
                        ? LjlColors.teal.withOpacity(0.1)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedLocation != null
                            ? LjlColors.teal
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      hintText: 'Calle y número',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'Ciudad *'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Requerido' : null,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(labelText: 'Provincia *'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Requerido' : null,
                          enabled: !isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detalles
                  _buildSectionTitle('Detalles de la Propiedad'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          label: 'Habitaciones',
                          value: _bedrooms,
                          onChanged: (val) => setState(() => _bedrooms = val),
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          label: 'Baños',
                          value: _bathrooms,
                          onChanged: (val) => setState(() => _bathrooms = val),
                          enabled: !isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _areaSqmController,
                          decoration: const InputDecoration(
                            labelText: 'Área (m²)',
                            hintText: 'Opcional',
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _floorNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Piso',
                            hintText: 'Opcional',
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          label: 'Ocupantes máx.',
                          value: _maxOccupants,
                          onChanged: (val) => setState(() => _maxOccupants = val),
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          label: 'Estadía mín. (meses)',
                          value: _minStayMonths,
                          onChanged: (val) => setState(() => _minStayMonths = val),
                          enabled: !isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Precio
                  _buildSectionTitle('Precio'),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      prefixText: '\$ ',
                      hintText: '500.00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo requerido';
                      if (double.tryParse(value!) == null) return 'Precio inválido';
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _pricePeriod,
                    decoration: const InputDecoration(labelText: 'Período'),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Diario')),
                      DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                      DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                      DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) => setState(() => _pricePeriod = value!),
                  ),
                  const SizedBox(height: 24),

                  // Servicios
                  _buildSectionTitle('Servicios Incluidos'),
                  _buildSwitchTile(
                    'Servicios (agua, luz, gas)',
                    _utilitiesIncluded,
                    (val) => setState(() => _utilitiesIncluded = val),
                    isLoading,
                  ),
                  _buildSwitchTile(
                    'WiFi',
                    _wifiIncluded,
                    (val) => setState(() => _wifiIncluded = val),
                    isLoading,
                  ),
                  _buildSwitchTile(
                    'Estacionamiento',
                    _parkingIncluded,
                    (val) => setState(() => _parkingIncluded = val),
                    isLoading,
                  ),
                  _buildSwitchTile(
                    'Amueblado',
                    _furnished,
                    (val) => setState(() => _furnished = val),
                    isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Reglas
                  _buildSectionTitle('Reglas de la Propiedad'),
                  _buildSwitchTile(
                    'Mascotas permitidas',
                    _petsAllowed,
                    (val) => setState(() => _petsAllowed = val),
                    isLoading,
                  ),
                  _buildSwitchTile(
                    'Fumar permitido',
                    _smokingAllowed,
                    (val) => setState(() => _smokingAllowed = val),
                    isLoading,
                  ),
                  _buildSwitchTile(
                    'Invitados permitidos',
                    _guestsAllowed,
                    (val) => setState(() => _guestsAllowed = val),
                    isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Amenidades
                  _buildSectionTitle('Amenidades'),
                  Wrap(
                    spacing: 8,
                    children: _availableAmenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAmenities.add(amenity);
                                  } else {
                                    _selectedAmenities.remove(amenity);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Imágenes
                  _buildSectionTitle('Imágenes'),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(_selectedImagePaths.isEmpty
                        ? 'Agregar Imágenes'
                        : '${_selectedImagePaths.length} imagen(es) seleccionada(s)'),
                  ),
                  if (_selectedImagePaths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _selectedImagePaths[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 16),
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          _selectedImagePaths.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Botón Guardar
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Registrar Propiedad'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: LjlColors.navy,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required bool enabled,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        IconButton(
          onPressed: enabled && value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: enabled ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    bool disabled,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: disabled ? null : onChanged,
      activeColor: LjlColors.teal,
    );
  }

  Future<void> _pickLocation() async {
    final location = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLocation: _selectedLocation),
      ),
    );

    if (location != null) {
      setState(() => _selectedLocation = location);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImagePaths = images.map((img) => img.path).toList();
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona la ubicación en el mapa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final property = UserProperty(
      id: '',
      ownerId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyType: _propertyType,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      location: _selectedLocation!,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      areaSqm: double.tryParse(_areaSqmController.text),
      floorNumber: int.tryParse(_floorNumberController.text),
      price: double.parse(_priceController.text),
      pricePeriod: _pricePeriod,
      utilitiesIncluded: _utilitiesIncluded,
      wifiIncluded: _wifiIncluded,
      parkingIncluded: _parkingIncluded,
      furnished: _furnished,
      amenities: _selectedAmenities,
      petsAllowed: _petsAllowed,
      smokingAllowed: _smokingAllowed,
      guestsAllowed: _guestsAllowed,
      minStayMonths: _minStayMonths,
      maxOccupants: _maxOccupants,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<UserPropertyBloc>().add(
          UserPropertyCreateRequested(property: property),
        );
  }
}