part of 'security_bloc.dart';

class SecurityState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final Verification? verification;
  final List<UserBlock> blockedUsers;
  final List<Reference> references;
  final int verifiedCount;
  final bool verificationCodeSent;

  const SecurityState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.verification,
    this.blockedUsers = const [],
    this.references = const [],
    this.verifiedCount = 0,
    this.verificationCodeSent = false,
  });

  // 🔥 CORREGIDO: copyWith con manejo correcto de nullable values
  SecurityState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error, // 🔥 PROBLEMA: No puedes resetear a null con esta sintaxis
    Verification? verification,
    List<UserBlock>? blockedUsers,
    List<Reference>? references,
    int? verifiedCount,
    bool? verificationCodeSent,
    // 🔥 NUEVO: Flags explícitos para resetear valores
    bool clearError = false,
    bool clearVerificationCodeSent = false,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      // 🔥 CORREGIDO: Si clearError es true, usar null, sino usar el valor pasado o el actual
      error: clearError ? null : (error ?? this.error),
      verification: verification ?? this.verification,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      references: references ?? this.references,
      verifiedCount: verifiedCount ?? this.verifiedCount,
      // 🔥 CORREGIDO: Si clearVerificationCodeSent es true, usar false
      verificationCodeSent: clearVerificationCodeSent 
          ? false 
          : (verificationCodeSent ?? this.verificationCodeSent),
    );
  }

  // Getters existentes
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
        verifiedCount,
        verificationCodeSent,
      ];
}