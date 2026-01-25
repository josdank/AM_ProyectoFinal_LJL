part of 'security_bloc.dart';

sealed class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class SecurityLoadRequested extends SecurityEvent {
  final String userId;
  const SecurityLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SecuritySubmitVerificationRequested extends SecurityEvent {
  final String userId;
  final String type;
  const SecuritySubmitVerificationRequested({
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

class SecurityReportUserRequested extends SecurityEvent {
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? details;

  const SecurityReportUserRequested({
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [reporterId, reportedId, reason, details];
}

class SecurityBlockUserRequested extends SecurityEvent {
  final String blockerId;
  final String blockedId;
  const SecurityBlockUserRequested({
    required this.blockerId,
    required this.blockedId,
  });

  @override
  List<Object?> get props => [blockerId, blockedId];
}

// ===== REFERENCIAS =====
class SecurityAddReferenceRequested extends SecurityEvent {
  final String userId;
  final String refereeName;
  final String refereeEmail;
  final String refereePhone;
  final String relationship;
  final String? comments;
  final int? rating;

  const SecurityAddReferenceRequested({
    required this.userId,
    required this.refereeName,
    required this.refereeEmail,
    required this.refereePhone,
    required this.relationship,
    this.comments,
    this.rating,
  });

  @override
  List<Object?> get props => [
        userId,
        refereeName,
        refereeEmail,
        refereePhone,
        relationship,
        comments,
        rating,
      ];
}

class SecurityUpdateReferenceRequested extends SecurityEvent {
  final String userId;
  final Reference reference;

  const SecurityUpdateReferenceRequested({
    required this.userId,
    required this.reference,
  });

  @override
  List<Object?> get props => [userId, reference];
}

class SecurityDeleteReferenceRequested extends SecurityEvent {
  final String userId;
  final String referenceId;

  const SecurityDeleteReferenceRequested({
    required this.userId,
    required this.referenceId,
  });

  @override
  List<Object?> get props => [userId, referenceId];
}

class SecuritySendVerificationCodeRequested extends SecurityEvent {
  final String referenceId;
  final String refereeEmail;

  const SecuritySendVerificationCodeRequested({
    required this.referenceId,
    required this.refereeEmail,
  });

  @override
  List<Object?> get props => [referenceId, refereeEmail];
}

class SecurityVerifyReferenceRequested extends SecurityEvent {
  final String userId;
  final String referenceId;
  final String code;

  const SecurityVerifyReferenceRequested({
    required this.userId,
    required this.referenceId,
    required this.code,
  });

  @override
  List<Object?> get props => [userId, referenceId, code];
}
