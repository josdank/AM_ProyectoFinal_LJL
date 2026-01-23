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
  const SecuritySubmitVerificationRequested({required this.userId, required this.type});

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
  const SecurityBlockUserRequested({required this.blockerId, required this.blockedId});

  @override
  List<Object?> get props => [blockerId, blockedId];
}
