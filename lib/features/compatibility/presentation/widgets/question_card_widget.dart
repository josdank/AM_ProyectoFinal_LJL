import 'package:flutter/material.dart';

/// Card reutilizable para mostrar preguntas del cuestionario
class QuestionCardWidget extends StatelessWidget {
  final String question;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final bool required;

  const QuestionCardWidget({
    super.key,
    required this.question,
    this.subtitle,
    this.icon,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pregunta
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      children: required
                          ? [
                              const TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Contenido
            child,
          ],
        ),
      ),
    );
  }
}

/// Widget para preguntas con escala (slider)
class ScaleQuestionWidget extends StatelessWidget {
  final String question;
  final int value;
  final int min;
  final int max;
  final List<String> labels;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final IconData? icon;

  const ScaleQuestionWidget({
    super.key,
    required this.question,
    required this.value,
    required this.min,
    required this.max,
    required this.labels,
    required this.onChanged,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCardWidget(
      question: question,
      icon: icon,
      child: Column(
        children: [
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: labels[value - min],
            onChanged: enabled ? (v) => onChanged(v.round()) : null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels.first,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                labels[value - min],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                labels.last,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para preguntas de sí/no
class BooleanQuestionWidget extends StatelessWidget {
  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final IconData? icon;
  final String? subtitle;

  const BooleanQuestionWidget({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCardWidget(
      question: question,
      subtitle: subtitle,
      icon: icon,
      child: SwitchListTile(
        title: Text(value ? 'Sí' : 'No'),
        value: value,
        onChanged: enabled ? onChanged : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}