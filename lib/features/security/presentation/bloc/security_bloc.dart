import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_block.dart';
import '../../domain/entities/verification.dart';
import '../../domain/usecases/block_user.dart';
import '../../domain/usecases/get_blocked_users.dart';
import '../../domain/usecases/get_verification_status.dart';
import '../../domain/usecases/report_user.dart';
import '../../domain/usecases/submit_verification.dart';

import '../../domain/entities/reference.dart';
import '../../domain/usecases/add_reference.dart';
import '../../domain/usecases/get_user_references.dart';
import '../../domain/usecases/update_reference.dart';
import '../../domain/usecases/delete_reference.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../domain/usecases/verify_reference.dart';

part 'security_event.dart';
part 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final GetVerificationStatus getVerificationStatus;
  final SubmitVerification submitVerification;
  final ReportUser reportUser;
  final BlockUser blockUser;
  final GetBlockedUsers getBlockedUsers;
  final GetUserReferences getUserReferences;
  final AddReference addReference;
  final UpdateReference updateReference;
  final DeleteReference deleteReference;
  final SendVerificationCode sendVerificationCode;
  final VerifyReference verifyReference;

  SecurityBloc({
    required this.getVerificationStatus,
    required this.submitVerification,
    required this.reportUser,
    required this.blockUser,
    required this.getBlockedUsers,
    required this.getUserReferences,
    required this.addReference,
    required this.updateReference,
    required this.deleteReference,
    required this.sendVerificationCode,
    required this.verifyReference,
  }) : super(const SecurityState()) {
    on<SecurityLoadRequested>(_onLoad);
    on<SecuritySubmitVerificationRequested>(_onSubmitVerification);
    on<SecurityReportUserRequested>(_onReport);
    on<SecurityBlockUserRequested>(_onBlock);
    on<SecurityAddReferenceRequested>(_onAddReference);
    on<SecurityUpdateReferenceRequested>(_onUpdateReference);
    on<SecurityDeleteReferenceRequested>(_onDeleteReference);
    on<SecuritySendVerificationCodeRequested>(_onSendVerificationCode);
    on<SecurityVerifyReferenceRequested>(_onVerifyReference);
  }

  // ✅ MÉTODO CORREGIDO: Sin nested folds
  Future<void> _onLoad(
    SecurityLoadRequested event,
    Emitter<SecurityState> emit,
  ) async {
    // 🔥 IMPORTANTE: Evitar cargas múltiples simultáneas
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Cargar verificación
      Verification? verification;
      final verRes = await getVerificationStatus(
        GetVerificationStatusParams(userId: event.userId),
      );
      verRes.fold(
        (failure) {
          // No es crítico si falla
          verification = null;
        },
        (ver) => verification = ver,
      );

      // Cargar usuarios bloqueados
      List<UserBlock> blockedUsers = [];
      final blockedRes = await getBlockedUsers(
        GetBlockedUsersParams(blockerId: event.userId),
      );
      blockedRes.fold(
        (failure) {
          // No es crítico si falla
          blockedUsers = [];
        },
        (blocked) => blockedUsers = blocked,
      );

      // Cargar referencias
      List<Reference> references = [];
      final referencesRes = await getUserReferences(
        GetUserReferencesParams(userId: event.userId),
      );
      referencesRes.fold(
        (failure) {
          // No es crítico si falla
          references = [];
        },
        (refs) => references = refs,
      );

      // Calcular referencias verificadas
      final verifiedCount = references.where((r) => r.verified).length;

      // ✅ Emitir estado exitoso con toda la data
      emit(state.copyWith(
        isLoading: false,
        verification: verification,
        blockedUsers: blockedUsers,
        references: references,
        verifiedCount: verifiedCount,
        error: null,
      ));
    } catch (e) {
      // ✅ IMPORTANTE: Emitir error pero NO recargar automáticamente
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos de seguridad: $e',
      ));
    }
  }

  Future<void> _onSubmitVerification(
    SecuritySubmitVerificationRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await submitVerification(
      SubmitVerificationParams(userId: event.userId, type: event.type),
    );
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (v) => emit(state.copyWith(isActionLoading: false, verification: v)),
    );
  }

  Future<void> _onReport(
    SecurityReportUserRequested event,
    Emitter<SecurityState> emit,
  ) async {
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

  Future<void> _onBlock(
    SecurityBlockUserRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await blockUser(
      BlockUserParams(blockerId: event.blockerId, blockedId: event.blockedId),
    );
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) {
        // ✅ Recargar después de bloquear exitosamente
        emit(state.copyWith(isActionLoading: false));
        add(SecurityLoadRequested(userId: event.blockerId));
      },
    );
  }

  // ===== REFERENCIAS =====

  Future<void> _onAddReference(
    SecurityAddReferenceRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await addReference(AddReferenceParams(
      userId: event.userId,
      refereeName: event.refereeName,
      refereeEmail: event.refereeEmail,
      refereePhone: event.refereePhone,
      relationship: event.relationship,
      comments: event.comments,
      rating: event.rating,
    ));
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) {
        emit(state.copyWith(isActionLoading: false));
        add(SecurityLoadRequested(userId: event.userId));
      },
    );
  }

  Future<void> _onUpdateReference(
    SecurityUpdateReferenceRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await updateReference(
      UpdateReferenceParams(reference: event.reference),
    );
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) {
        emit(state.copyWith(isActionLoading: false));
        add(SecurityLoadRequested(userId: event.userId));
      },
    );
  }

  Future<void> _onDeleteReference(
    SecurityDeleteReferenceRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await deleteReference(
      DeleteReferenceParams(referenceId: event.referenceId),
    );
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) {
        emit(state.copyWith(isActionLoading: false));
        add(SecurityLoadRequested(userId: event.userId));
      },
    );
  }

  Future<void> _onSendVerificationCode(
    SecuritySendVerificationCodeRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await sendVerificationCode(SendVerificationCodeParams(
      referenceId: event.referenceId,
      refereeEmail: event.refereeEmail,
    ));
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (code) {
        emit(state.copyWith(
          isActionLoading: false,
          verificationCodeSent: true,
        ));
      },
    );
  }

  Future<void> _onVerifyReference(
    SecurityVerifyReferenceRequested event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, error: null));
    
    final res = await verifyReference(VerifyReferenceParams(
      referenceId: event.referenceId,
      code: event.code,
    ));
    
    res.fold(
      (l) => emit(state.copyWith(isActionLoading: false, error: l.message)),
      (_) {
        emit(state.copyWith(isActionLoading: false));
        add(SecurityLoadRequested(userId: event.userId));
      },
    );
  }
}