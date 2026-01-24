import 'package:equatable/equatable.dart';

class Match extends Equatable {
  final String id;
  final String userAId;
  final String userBId;
  final String? listingId;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.listingId,
    required this.createdAt,
  });

  String otherUserId(String myId) => myId == userAId ? userBId : userAId;

  @override
  List<Object?> get props => [id, userAId, userBId, listingId, createdAt];
}
