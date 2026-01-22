import 'package:flutter/material.dart';
import '../../domain/entities/profile.dart';

class ProfileInfoCardWidget extends StatelessWidget {
  final Profile profile;

  const ProfileInfoCardWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biografía
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.info_outline,
                title: 'Sobre mí',
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                profile.bio!,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const Divider(height: 32),
            ],

            // Información personal
            _SectionHeader(
              icon: Icons.person_outline,
              title: 'Información Personal',
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),

            if (profile.gender != null)
              _InfoRow(
                icon: Icons.wc,
                label: 'Género',
                value: profile.gender!,
              ),

            if (profile.occupation != null)
              _InfoRow(
                icon: Icons.work_outline,
                label: 'Ocupación',
                value: profile.occupation!,
              ),

            if (profile.university != null)
              _InfoRow(
                icon: Icons.school_outlined,
                label: 'Universidad',
                value: profile.university!,
              ),

            if (profile.phoneNumber != null)
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: profile.phoneNumber!,
              ),

            if (profile.birthDate != null)
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'Fecha de Nacimiento',
                value: _formatDate(profile.birthDate!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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