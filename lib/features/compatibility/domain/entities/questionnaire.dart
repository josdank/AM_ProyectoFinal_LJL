import 'package:equatable/equatable.dart';

class Questionnaire extends Equatable {
  final String id;
  final String userId;
  final Map<String, dynamic> responses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Questionnaire({
    required this.id,
    required this.userId,
    required this.responses,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, responses, createdAt, updatedAt];
}

