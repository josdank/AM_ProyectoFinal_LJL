part of 'security_bloc.dart';

class SecurityState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final Verification? verification;
  final List<UserBlock> blockedUsers;
  final List<Reference> references; // NUEVO
  final bool verificationCodeSent; // NUEVO

  const SecurityState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.verification,
    this.blockedUsers = const [],
    this.references = const [], // NUEVO
    this.verificationCodeSent = false, // NUEVO
  });

  SecurityState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    Verification? verification,
    List<UserBlock>? blockedUsers,
    List<Reference>? references, // NUEVO
    bool? verificationCodeSent, // NUEVO
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: error,
      verification: verification ?? this.verification,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      references: references ?? this.references, // NUEVO
      verificationCodeSent: verificationCodeSent ?? this.verificationCodeSent, // NUEVO
    );
  }

  // NUEVO: Getters útiles para referencias
  List<Reference> get verifiedReferences => 
      references.where((ref) => ref.isVerified).toList();
  
  List<Reference> get unverifiedReferences => 
      references.where((ref) => !ref.isVerified).toList();
  
  int get totalReferences => references.length;
  int get verifiedCount => verifiedReferences.length;

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        error,
        verification,
        blockedUsers,
        references, // NUEVO
        verificationCodeSent, // NUEVO
      ];
}