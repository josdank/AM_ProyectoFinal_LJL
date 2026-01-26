part of 'security_bloc.dart';

class SecurityState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final Verification? verification;
  final List<UserBlock> blockedUsers;
  final List<Reference> references; 
  final int verifiedCount; // NUEVO
  final bool verificationCodeSent; 

  const SecurityState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.verification,
    this.blockedUsers = const [],
    this.references = const [], 
    this.verifiedCount = 0, // NUEVO
    this.verificationCodeSent = false, 
  });

  SecurityState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    Verification? verification,
    List<UserBlock>? blockedUsers,
    List<Reference>? references, 
    int? verifiedCount, // NUEVO
    bool? verificationCodeSent, 
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: error,
      verification: verification ?? this.verification,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      references: references ?? this.references, 
      verifiedCount: verifiedCount ?? this.verifiedCount, // NUEVO
      verificationCodeSent:
          verificationCodeSent ?? this.verificationCodeSent, 
    );
  }

  // Getters existentes (no se eliminan)
  List<Reference> get verifiedReferences =>
      references.where((ref) => ref.isVerified).toList();

  List<Reference> get unverifiedReferences =>
      references.where((ref) => !ref.isVerified).toList();

  int get totalReferences => references.length;

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        error,
        verification,
        blockedUsers,
        references,
        verifiedCount, // NUEVO
        verificationCodeSent,
      ];
}
