import 'package:equatable/equatable.dart';

class CompatibilityScore extends Equatable {
  final String userId1;
  final String userId2;
  final double overallScore; // 0-100
  final Map<String, double> categoryScores; // Scores por categoría
  final List<String> strengths; // Áreas de alta compatibilidad
  final List<String> potentialIssues; // Áreas de baja compatibilidad

  const CompatibilityScore({
    required this.userId1,
    required this.userId2,
    required this.overallScore,
    required this.categoryScores,
    required this.strengths,
    required this.potentialIssues,
  });

  String get compatibilityLevel {
    if (overallScore >= 80) return 'Excelente';
    if (overallScore >= 65) return 'Muy Buena';
    if (overallScore >= 50) return 'Buena';
    if (overallScore >= 35) return 'Regular';
    return 'Baja';
  }

  @override
  List<Object?> get props => [
        userId1,
        userId2,
        overallScore,
        categoryScores,
        strengths,
        potentialIssues,
      ];
}