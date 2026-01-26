import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/ljl_colors.dart';
import '../../domain/entities/user_property.dart';
import '../bloc/user_property_bloc.dart';

class EditPropertyPage extends StatefulWidget {
  final UserProperty property;

  const EditPropertyPage({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  late bool _isActive;
  late bool _utilitiesIncluded;
  late bool _wifiIncluded;
  late bool _parkingIncluded;
  late bool _furnished;
  late bool _petsAllowed;
  late bool _smokingAllowed;
  late bool _guestsAllowed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(text: widget.property.description);
    _priceController = TextEditingController(text: widget.property.price.toString());

    _isActive = widget.property.isActive;
    _utilitiesIncluded = widget.property.utilitiesIncluded;
    _wifiIncluded = widget.property.wifiIncluded;
    _parkingIncluded = widget.property.parkingIncluded;
    _furnished = widget.property.furnished;
    _petsAllowed = widget.property.petsAllowed;
    _smokingAllowed = widget.property.smokingAllowed;
    _guestsAllowed = widget.property.guestsAllowed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserPropertyBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Propiedad'),
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

            if (state is UserPropertyUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Propiedad actualizada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            final isLoading = state is UserPropertyUpdating;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Estado
                  SwitchListTile(
                    title: const Text('Propiedad Activa'),
                    subtitle: Text(
                      _isActive
                          ? 'Visible en el mapa'
                          : 'No visible en el mapa',
                    ),
                    value: _isActive,
                    onChanged: isLoading ? null : (val) => setState(() => _isActive = val),
                    activeColor: LjlColors.teal,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la Propiedad *',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                    ),
                    maxLines: 4,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo requerido';
                      if (double.tryParse(value!) == null) return 'Precio inválido';
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Servicios
                  const Text(
                    'Servicios Incluidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const Text(
                    'Reglas de la Propiedad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 32),

                  // Información de ubicación (solo lectura)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${widget.property.address}'),
                        Text('${widget.property.city}, ${widget.property.state}'),
                        const SizedBox(height: 8),
                        const Text(
                          'La ubicación no se puede cambiar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Guardar
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar Cambios'),
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

    final updatedProperty = widget.property.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      isActive: _isActive,
      utilitiesIncluded: _utilitiesIncluded,
      wifiIncluded: _wifiIncluded,
      parkingIncluded: _parkingIncluded,
      furnished: _furnished,
      petsAllowed: _petsAllowed,
      smokingAllowed: _smokingAllowed,
      guestsAllowed: _guestsAllowed,
      updatedAt: DateTime.now(),
    );

    context.read<UserPropertyBloc>().add(
          UserPropertyUpdateRequested(property: updatedProperty),
        );
  }
}