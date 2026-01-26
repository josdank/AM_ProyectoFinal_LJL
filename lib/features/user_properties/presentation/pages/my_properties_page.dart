import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/ljl_colors.dart';
import '../bloc/user_property_bloc.dart';
import '../widgets/property_card_widget.dart';
import 'create_property_page.dart';
import 'edit_property_page.dart';

class MyPropertiesPage extends StatelessWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return BlocProvider(
      create: (_) => sl<UserPropertyBloc>()
        ..add(UserPropertyLoadMyPropertiesRequested(ownerId: userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Propiedades'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<UserPropertyBloc>().add(
                      UserPropertyLoadMyPropertiesRequested(ownerId: userId),
                    );
              },
            ),
          ],
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

            if (state is UserPropertyDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Propiedad eliminada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recargar lista
              context.read<UserPropertyBloc>().add(
                    UserPropertyLoadMyPropertiesRequested(ownerId: userId),
                  );
            }
          },
          builder: (context, state) {
            if (state is UserPropertyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserPropertyLoaded) {
              if (state.properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes propiedades registradas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra tu primera propiedad',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToCreateProperty(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar Propiedad'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<UserPropertyBloc>().add(
                        UserPropertyLoadMyPropertiesRequested(ownerId: userId),
                      );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.properties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final property = state.properties[index];
                    return PropertyCardWidget(
                      property: property,
                      onTap: () => _navigateToEditProperty(context, property),
                      onToggleStatus: () {
                        context.read<UserPropertyBloc>().add(
                              UserPropertyToggleStatusRequested(
                                propertyId: property.id,
                                isActive: !property.isActive,
                              ),
                            );
                      },
                      onDelete: () => _confirmDelete(context, property.id),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateProperty(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Propiedad'),
          backgroundColor: LjlColors.gold,
          foregroundColor: LjlColors.navy,
        ),
      ),
    );
  }

  void _navigateToCreateProperty(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UserPropertyBloc>(), // ✅ Pasar el Bloc existente
          child: const CreatePropertyPage(),
        ),
      ),
    );

    // ✅ Recargar automáticamente si hubo éxito
    if (result == true && context.mounted) {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      context.read<UserPropertyBloc>().add(
        UserPropertyLoadMyPropertiesRequested(ownerId: userId),
      );
    }
  }

  void _navigateToEditProperty(BuildContext context, property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPropertyPage(property: property),
      ),
    );

    if (result == true && context.mounted) {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      context.read<UserPropertyBloc>().add(
            UserPropertyLoadMyPropertiesRequested(ownerId: userId),
          );
    }
  }

  void _confirmDelete(BuildContext context, String propertyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Propiedad'),
        content: const Text(
          '¿Estás seguro que deseas eliminar esta propiedad? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserPropertyBloc>().add(
                    UserPropertyDeleteRequested(propertyId: propertyId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}