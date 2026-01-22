import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/listing_card_widget.dart';
import 'create_listing_page.dart';
import 'listing_detail_page.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Publicaciones'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('No autenticado'));
          }

          return BlocBuilder<ListingBloc, ListingState>(
            builder: (context, listingState) {
              if (listingState is ListingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (listingState is ListingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(listingState.message),
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

              final allListings = listingState is ListingsLoaded
                  ? listingState.listings
                  : <Listing>[];

              // Filtrar solo las publicaciones del usuario
              final myListings = allListings
                  .where((listing) => listing.ownerId == authState.user.id)
                  .toList();

              if (myListings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_outlined,
                          size: 100, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes publicaciones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primera publicación',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateListingPage(
                                userId: authState.user.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva Publicación'),
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
                  itemCount: myListings.length,
                  itemBuilder: (context, index) {
                    final listing = myListings[index];
                    return Dismissible(
                      key: Key(listing.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                '¿Estás seguro de eliminar esta publicación?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        context.read<ListingBloc>().add(
                              ListingDeleteRequested(listingId: listing.id),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Publicación eliminada')),
                        );
                      },
                      child: ListingCardWidget(
                        listing: listing,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailPage(listing: listing),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ListingBloc>(),
                    child: CreateListingPage(userId: authState.user.id),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Publicación'),
          );
        },
      ),
    );
  }
}