import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../compatibility/domain/entities/habits.dart';
import '../../../compatibility/presentation/bloc/compatibility_bloc.dart';
import '../../../compatibility/presentation/pages/questionnaire_page.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import 'edit_profile_page.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_card_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: Text('No autenticado')));
        }

        // CORRECCIÓN: NO crear un nuevo BlocProvider aquí
        // El ProfileBloc ya existe en el contexto superior (HomePage)
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            actions: [
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoaded) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.of(context).push<Profile>(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProfileBloc>(),
                              child: EditProfilePage(profile: state.profile),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfileError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProfileBloc>().add(
                            ProfileLoadRequested(userId: authState.user.id),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ProfileLoaded) {
                return _ProfileContent(profile: state.profile);
              }

              return const Center(child: Text('Estado desconocido'));
            },
          ),
          floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Habits>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: sl<CompatibilityBloc>(),
                          child: QuestionnairePage(userId: state.profile.id),
                        ),
                      ),
                    );
                    if (result != null && context.mounted) {
                      sl<CompatibilityBloc>().add(
                        SaveHabitsRequested(habits: result),
                      );

                      // ✅ NUEVO: Actualizar el perfil para marcar como completo
                      final updatedProfile = Profile(
                        id: state.profile.id,
                        fullName: state.profile.fullName,
                        bio: state.profile.bio,
                        photoUrl: state.profile.photoUrl,
                        birthDate: state.profile.birthDate,
                        gender: state.profile.gender,
                        occupation: state.profile.occupation,
                        university: state.profile.university,
                        phoneNumber: state.profile.phoneNumber,
                        isProfileComplete: true,
                        createdAt: state.profile.createdAt,
                        updatedAt: DateTime.now(),
                      );

                      context.read<ProfileBloc>().add(
                        ProfileUpdateRequested(profile: updatedProfile),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cuestionario guardado y perfil actualizado',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.quiz),
                  label: const Text('Cuestionario'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Profile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderWidget(
            profile: profile,
            isOwnProfile: true,
            onEditPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: EditProfilePage(profile: profile),
                  ),
                ),
              );
            },
          ),
          ProfileInfoCardWidget(profile: profile),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
