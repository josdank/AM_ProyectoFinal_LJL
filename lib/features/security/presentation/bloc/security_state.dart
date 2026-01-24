part of 'security_bloc.dart';

class SecurityState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final Verification? verification;
  final List<UserBlock> blockedUsers;

  const SecurityState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.verification,
    this.blockedUsers = const [],
  });

  SecurityState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    Verification? verification,
    List<UserBlock>? blockedUsers,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: error,
      verification: verification ?? this.verification,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  @override
  List<Object?> get props => [isLoading, isActionLoading, error, verification, blockedUsers];
}
