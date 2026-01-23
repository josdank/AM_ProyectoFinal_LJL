import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _universityController;
  late TextEditingController _phoneController;
  
  DateTime? _selectedBirthDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _occupationController = TextEditingController(text: widget.profile.occupation ?? '');
    _universityController = TextEditingController(text: widget.profile.university ?? '');
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _selectedBirthDate = widget.profile.birthDate;
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _universityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      context.read<ProfileBloc>().add(
            ProfilePhotoUploadRequested(
              photo: image,
              userId: widget.profile.id,
            ),
          );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Verificar si el perfil está completo
      final isComplete = _fullNameController.text.isNotEmpty &&
          _selectedBirthDate != null &&
          _selectedGender != null;

      final updatedProfile = Profile(
        id: widget.profile.id,
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        photoUrl: widget.profile.photoUrl,
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        university: _universityController.text.trim().isEmpty
            ? null
            : _universityController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        isProfileComplete: isComplete,
        createdAt: widget.profile.createdAt,
        updatedAt: DateTime.now(),
      );


      context.read<ProfileBloc>().add(
            ProfileUpdateRequested(profile: updatedProfile),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado')),
            );
            Navigator.of(context).pop(state.profile);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating || state is ProfileUploadingPhoto;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto de perfil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.profile.photoUrl != null
                              ? NetworkImage(widget.profile.photoUrl!)
                              : null,
                          child: widget.profile.photoUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: isLoading ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre completo
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Biografía
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Biografía',
                      prefixIcon: Icon(Icons.edit_note),
                      hintText: 'Cuéntanos sobre ti...',
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Fecha de nacimiento
                  InkWell(
                    onTap: isLoading ? null : () => _selectBirthDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de Nacimiento *',
                        prefixIcon: const Icon(Icons.cake),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: isLoading ? null : () => _selectBirthDate(context),
                        ),
                      ),
                      child: Text(
                        _selectedBirthDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
                            : 'Selecciona tu fecha de nacimiento',
                        style: TextStyle(
                          color: _selectedBirthDate != null
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Género
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Género *',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      DropdownMenuItem(value: 'Prefiero no decir', child: Text('Prefiero no decir')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Ocupación
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(
                      labelText: 'Ocupación',
                      prefixIcon: Icon(Icons.work),
                      hintText: 'Ej: Estudiante, Profesional',
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Universidad
                  TextFormField(
                    controller: _universityController,
                    decoration: const InputDecoration(
                      labelText: 'Universidad',
                      prefixIcon: Icon(Icons.school),
                      hintText: 'Ej: Universidad Central',
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '0987654321',
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Indicador de progreso
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),

                  const SizedBox(height: 8),
                  const Text(
                    '* Campos requeridos',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}