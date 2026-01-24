part of 'connection_bloc.dart';

class ConnectionState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final List<ConnectionRequest> incoming;
  final List<ConnectionRequest> outgoing;
  final List<Match> matches;

  const ConnectionState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.incoming = const [],
    this.outgoing = const [],
    this.matches = const [],
  });

  ConnectionState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    List<ConnectionRequest>? incoming,
    List<ConnectionRequest>? outgoing,
    List<Match>? matches,
  }) {
    return ConnectionState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: error,
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      matches: matches ?? this.matches,
    );
  }

  @override
  List<Object?> get props => [isLoading, isActionLoading, error, incoming, outgoing, matches];
}
