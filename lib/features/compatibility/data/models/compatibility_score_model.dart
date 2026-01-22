import '../../domain/entities/compatibility_score.dart';

class CompatibilityScoreModel extends CompatibilityScore {
  const CompatibilityScoreModel({
    required super.userId1,
    required super.userId2,
    required super.overallScore,
    required super.categoryScores,
    required super.strengths,
    required super.potentialIssues,
  });

  factory CompatibilityScoreModel.fromJson(Map<String, dynamic> json) {
    return CompatibilityScoreModel(
      userId1: json['user_id_1'] as String,
      userId2: json['user_id_2'] as String,
      overallScore: (json['overall_score'] as num).toDouble(),
      categoryScores: Map<String, double>.from(
        (json['category_scores'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      strengths: List<String>.from(json['strengths'] as List),
      potentialIssues: List<String>.from(json['potential_issues'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id_1': userId1,
      'user_id_2': userId2,
      'overall_score': overallScore,
      'category_scores': categoryScores,
      'strengths': strengths,
      'potential_issues': potentialIssues,
    };
  }

  CompatibilityScore toEntity() => CompatibilityScore(
        userId1: userId1,
        userId2: userId2,
        overallScore: overallScore,
        categoryScores: categoryScores,
        strengths: strengths,
        potentialIssues: potentialIssues,
      );
}

