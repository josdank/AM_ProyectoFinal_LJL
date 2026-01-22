class QuestionnaireModel {
  final String id;
  final String userId;
  final Map<String, dynamic> responses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionnaireModel({
    required this.id,
    required this.userId,
    required this.responses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'responses': responses,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

