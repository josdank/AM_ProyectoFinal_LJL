import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_block.dart';
import '../../domain/entities/verification.dart';
import '../../domain/usecases/block_user.dart';
import '../../domain/usecases/get_blocked_users.dart';
import '../../domain/usecases/get_verification_status.dart';
import '../../domain/usecases/report_user.dart';
import '../../domain/usecases/submit_verification.dart';

part 'security_event.dart';
part 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final GetVerificationStatus getVerificationStatus;
  final SubmitVerification submitVerification;
  final ReportUser reportUser;
  final BlockUser blockUser;
  final GetBlockedUsers getBlockedUsers;

  SecurityBloc({
    required this.getVerificationStatus,
    required this.submitVerification,
    required this.reportUser,
    required this.blockUser,
    required this.getBlockedUsers,
  }) : super(const SecurityState()) {
    on<SecurityLoadRequested>(_onLoad);
    on<SecuritySubmitVerificationRequested>(_onSubmitVerification);
    on<SecurityReportUserRequested>(_onReport);
    on<SecurityBlockUserRequested>(_onBlock);
  }

  Future<void> _onLoad(SecurityLoadRequested event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final verRes = await getVerificationStatus(GetVerificationStatusParams(userId: event.userId));
    final blockedRes = await getBlockedUsers(GetBlockedUsersParams(blockerId: event.userId));

    verRes.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (verification) {
        blockedRes.fold(
          (l) => emit(state.copyWith(isLoading: false, error: l.message)),
          (blocked) => emit(
            state.copyWith(
              isLoading: false,
              verification: verification,
              blockedUsers: blocked,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSubmitVerification(SecuritySubmitVerificationRequested event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await submitVerification(SubmitVerificationParams(userId: event.userId, type: event.type));
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (v) => emit(state.copyWith(isActionLoading: false, verification: v)),
    );
  }

  Future<void> _onReport(SecurityReportUserRequested event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await reportUser(ReportUserParams(
      reporterId: event.reporterId,
      reportedId: event.reportedId,
      reason: event.reason,
      details: event.details,
    ));
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }

  Future<void> _onBlock(SecurityBlockUserRequested event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    final res = await blockUser(BlockUserParams(blockerId: event.blockerId, blockedId: event.blockedId));
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) => add(SecurityLoadRequested(userId: event.blockerId)),
    );
  }
}
