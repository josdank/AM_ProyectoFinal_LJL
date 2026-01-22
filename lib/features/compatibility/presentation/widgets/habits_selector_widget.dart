import 'package:flutter/material.dart';

/// Widget reutilizable para seleccionar un hábito con opciones
class HabitsSelectorWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<HabitOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const HabitsSelectorWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Opciones
            ...options.map((option) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    if (option.emoji != null) ...[
                      Text(option.emoji!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: Text(option.label)),
                  ],
                ),
                subtitle: option.description != null
                    ? Text(option.description!)
                    : null,
                value: option.value,
                groupValue: selectedValue,
                onChanged: enabled ? onChanged : null,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class HabitOption {
  final String value;
  final String label;
  final String? description;
  final String? emoji;

  const HabitOption({
    required this.value,
    required this.label,
    this.description,
    this.emoji,
  });
}
