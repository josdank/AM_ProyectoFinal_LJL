import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/recommendations/recommendation_service.dart';
import '../../../../core/theme/ljl_colors.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/widgets/listing_card_widget.dart';
import '../cubit/tenant_cubit.dart';
import 'tenant_requests_page.dart';
import 'tenant_favorites_page.dart';

class TenantHomePage extends StatefulWidget {
  const TenantHomePage({super.key});

  @override
  State<TenantHomePage> createState() => _TenantHomePageState();
}

class _TenantHomePageState extends State<TenantHomePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<TenantCubit>().loadAll(tenantId: userId);
      context.read<ListingBloc>().add(const ListingsLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _TenantListingsTab(),
      const TenantFavoritesPage(),
      const TenantRequestsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrendatario'),
        actions: [
          IconButton(
            tooltip: 'Tema',
            onPressed: () {
              // Dejar la acción para Settings (si la integras en el menú)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('En Ajustes podrás cambiar el tema (dark mode).')),
              );
            },
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: tabs[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Solicitudes'),
        ],
      ),
    );
  }
}

class _TenantListingsTab extends StatelessWidget {
  const _TenantListingsTab();

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ListingsError) {
          return Center(child: Text(state.message, textAlign: TextAlign.center));
        }
        if (state is! ListingsLoaded) {
          return const SizedBox.shrink();
        }

        final listings = state.listings;
        final rec = context.read<RecommendationService>().recommend(listings, limit: 6);

        return RefreshIndicator(
          onRefresh: () async => context.read<ListingBloc>().add(const ListingsLoadRequested()),
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // Recomendaciones
              if (rec.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: LjlColors.gold),
                    const SizedBox(width: 8),
                    Text(
                      'Sugeridos para ti',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 235,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) => SizedBox(
                      width: 320,
                      child: _TenantListingActions(
                        listing: rec[i],
                        tenantId: userId,
                        child: ListingCardWidget(listing: rec[i]),
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: rec.length,
                  ),
                ),
                const SizedBox(height: 18),
              ],

              Text(
                'Explora viviendas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              ...listings.map((l) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TenantListingActions(
                    listing: l,
                    tenantId: userId,
                    child: ListingCardWidget(listing: l),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TenantListingActions extends StatelessWidget {
  final Widget child;
  final Listing listing;
  final String tenantId;

  const _TenantListingActions({
    required this.child,
    required this.listing,
    required this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // track view for recs
                      await context.read<RecommendationService>().trackView(listing);
                      // toggle favorite
                      await context.read<TenantCubit>().toggleFavorite(tenantId: tenantId, listing: listing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorito actualizado')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Favorito'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final message = await _askMessage(context);
                      if (context.mounted) {
                        await context.read<TenantCubit>().applyToListing(
                              tenantId: tenantId,
                              listing: listing,
                              message: message,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solicitud enviada')),
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Contactar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _askMessage(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mensaje opcional'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Ej: Hola, estoy interesado. ¿Podemos coordinar una visita?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Omitir')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim().isEmpty ? null : ctrl.text.trim()), child: const Text('Enviar')),
        ],
      ),
    );
  }
}