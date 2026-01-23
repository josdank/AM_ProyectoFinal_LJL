import '../../domain/entities/match.dart';

class MatchModel extends Match {
  const MatchModel({
    required super.id,
    required super.userAId,
    required super.userBId,
    required super.listingId,
    required super.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'].toString(),
      userAId: json['user_a_id'] as String,
      userBId: json['user_b_id'] as String,
      listingId: json['listing_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_a_id': userAId,
      'user_b_id': userBId,
      'listing_id': listingId,
    };
  }
}
