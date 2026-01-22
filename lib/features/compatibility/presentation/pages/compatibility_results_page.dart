import 'package:flutter/material.dart';
import '../../domain/entities/compatibility_score.dart';
import '../widgets/compatibility_meter_widget.dart';

class CompatibilityResultsPage extends StatelessWidget {
  final CompatibilityScore score;

  const CompatibilityResultsPage({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de Compatibilidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meter principal
            Center(
              child: CompatibilityMeterWidget(
                score: score.overallScore,
                size: 250,
              ),
            ),
            const SizedBox(height: 32),

            // Scores por categoría
            _buildSectionTitle(context, '📊 Compatibilidad por Categorías'),
            const SizedBox(height: 16),
            _buildCategoryScores(),
            const SizedBox(height: 32),

            // Fortalezas
            if (score.strengths.isNotEmpty) ...[
              _buildSectionTitle(context, '✨ Fortalezas'),
              const SizedBox(height: 16),
              _buildStrengthsList(),
              const SizedBox(height: 32),
            ],

            // Áreas de mejora
            if (score.potentialIssues.isNotEmpty) ...[
              _buildSectionTitle(context, '⚠️ Áreas a Considerar'),
              const SizedBox(height: 16),
              _buildIssuesList(),
              const SizedBox(height: 32),
            ],

            // Interpretación
            _buildInterpretation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCategoryScores() {
    final categories = {
      'sleep': '😴 Sueño',
      'cleanliness': '🧹 Limpieza',
      'social': '👥 Social',
      'lifestyle': '🌟 Estilo de vida',
      'work': '💼 Trabajo',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: score.categoryScores.entries.map((entry) {
            final categoryName = categories[entry.key] ?? entry.key;
            final categoryScore = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${categoryScore.toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(categoryScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: categoryScore / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(_getScoreColor(categoryScore)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStrengthsList() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: score.strengths.map((strength) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(strength),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIssuesList() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: score.potentialIssues.map((issue) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(issue),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInterpretation(BuildContext context) {
    String interpretation;
    IconData icon;
    Color color;

    if (score.overallScore >= 80) {
      interpretation =
          'Excelente compatibilidad! Tienen muchas cosas en común y es probable que convivan armoniosamente.';
      icon = Icons.sentiment_very_satisfied;
      color = Colors.green;
    } else if (score.overallScore >= 65) {
      interpretation =
          'Muy buena compatibilidad. Aunque hay algunas diferencias, pueden funcionar muy bien juntos con comunicación.';
      icon = Icons.sentiment_satisfied;
      color = Colors.lightGreen;
    } else if (score.overallScore >= 50) {
      interpretation =
          'Compatibilidad aceptable. Tienen algunas diferencias importantes, pero con compromiso pueden llevarse bien.';
      icon = Icons.sentiment_neutral;
      color = Colors.orange;
    } else if (score.overallScore >= 35) {
      interpretation =
          'Compatibilidad regular. Hay varias diferencias que requerirán mucha comunicación y compromiso.';
      icon = Icons.sentiment_dissatisfied;
      color = Colors.deepOrange;
    } else {
      interpretation =
          'Baja compatibilidad. Tienen estilos de vida muy diferentes. Recomendamos considerar otras opciones.';
      icon = Icons.sentiment_very_dissatisfied;
      color = Colors.red;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interpretación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(interpretation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 65) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    if (score >= 35) return Colors.deepOrange;
    return Colors.red;
  }
}