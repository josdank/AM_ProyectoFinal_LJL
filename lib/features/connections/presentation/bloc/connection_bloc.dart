import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/match.dart';
import '../../domain/usecases/accept_interest.dart';
import '../../domain/usecases/get_incoming_interests.dart';
import '../../domain/usecases/get_matches.dart';
import '../../domain/usecases/get_outgoing_interests.dart';
import '../../domain/usecases/reject_interest.dart';
import '../../domain/usecases/send_interest.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final SendInterest sendInterest;
  final AcceptInterest acceptInterest;
  final RejectInterest rejectInterest;
  final GetIncomingInterests getIncoming;
  final GetOutgoingInterests getOutgoing;
  final GetMatches getMatches;

  ConnectionBloc({
    required this.sendInterest,
    required this.acceptInterest,
    required this.rejectInterest,
    required this.getIncoming,
    required this.getOutgoing,
    required this.getMatches,
  }) : super(const ConnectionState()) {
    on<ConnectionLoadRequested>(_onLoad);
    on<ConnectionSendInterestRequested>(_onSend);
    on<ConnectionAcceptRequested>(_onAccept);
    on<ConnectionRejectRequested>(_onReject);
  }

  Future<void> _onLoad(ConnectionLoadRequested event, Emitter<ConnectionState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final incomingRes = await getIncoming(GetIncomingInterestsParams(userId: event.userId));
    final outgoingRes = await getOutgoing(GetOutgoingInterestsParams(userId: event.userId));
    final matchesRes = await getMatches(GetMatchesParams(userId: event.userId));

    incomingRes.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (incoming) {
        outgoingRes.fold(
          (l) => emit(state.copyWith(isLoading: false, error: l.message)),
          (outgoing) {
            matchesRes.fold(
              (l) => emit(state.copyWith(isLoading: false, error: l.message)),
              (matches) => emit(
                state.copyWith(
                  isLoading: false,
                  incoming: incoming,
                  outgoing: outgoing,
                  matches: matches,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSend(ConnectionSendInterestRequested event, Emitter<ConnectionState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await sendInterest(
      SendInterestParams(fromUserId: event.fromUserId, toUserId: event.toUserId, listingId: event.listingId),
    );
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) => add(ConnectionLoadRequested(userId: event.fromUserId)),
    );
  }

  Future<void> _onAccept(ConnectionAcceptRequested event, Emitter<ConnectionState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await acceptInterest(AcceptInterestParams(requestId: event.requestId));
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) => add(ConnectionLoadRequested(userId: event.userId)),
    );
  }

  Future<void> _onReject(ConnectionRejectRequested event, Emitter<ConnectionState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await rejectInterest(RejectInterestParams(requestId: event.requestId));
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) => add(ConnectionLoadRequested(userId: event.userId)),
    );
  }
}
