part of 'connection_bloc.dart';

sealed class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

class ConnectionLoadRequested extends ConnectionEvent {
  final String userId;
  const ConnectionLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ConnectionSendInterestRequested extends ConnectionEvent {
  final String fromUserId;
  final String toUserId;
  final String? listingId;

  const ConnectionSendInterestRequested({
    required this.fromUserId,
    required this.toUserId,
    this.listingId,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, listingId];
}

class ConnectionAcceptRequested extends ConnectionEvent {
  final String userId;
  final String requestId;
  const ConnectionAcceptRequested({required this.userId, required this.requestId});

  @override
  List<Object?> get props => [userId, requestId];
}

class ConnectionRejectRequested extends ConnectionEvent {
  final String userId;
  final String requestId;
  const ConnectionRejectRequested({required this.userId, required this.requestId});

  @override
  List<Object?> get props => [userId, requestId];
}
