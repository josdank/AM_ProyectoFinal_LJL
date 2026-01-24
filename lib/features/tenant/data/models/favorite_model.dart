import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.userId,
    required super.listingId,
    required super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      listingId: json['listing_id'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
