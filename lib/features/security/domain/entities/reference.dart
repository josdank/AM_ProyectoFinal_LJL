import 'package:equatable/equatable.dart';

/// Entidad que representa una referencia de convivencia
class Reference extends Equatable {
  final String id;
  final String userId; // Usuario que proporciona la referencia
  final String refereeName; // Nombre de la persona que da la referencia
  final String refereeEmail; // Email del referente
  final String refereePhone; // Teléfono del referente
  final String relationship; // 'roommate', 'landlord', 'family', 'friend'
  final String? comments; // Comentarios sobre la convivencia
  final int? rating; // Rating de 1-5 (opcional)
  final bool verified; // Si la referencia fue verificada
  final String? verificationCode; // Código de verificación temporal
  final DateTime? codeExpiresAt; // Expiración del código
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reference({
    required this.id,
    required this.userId,
    required this.refereeName,
    required this.refereeEmail,
    required this.refereePhone,
    required this.relationship,
    this.comments,
    this.rating,
    this.verified = false,
    this.verificationCode,
    this.codeExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si la referencia está verificada
  bool get isVerified => verified;

  /// Verifica si el código de verificación ha expirado
  bool get isCodeExpired {
    if (codeExpiresAt == null) return true;
    return DateTime.now().isAfter(codeExpiresAt!);
  }

  /// Verifica si tiene rating
  bool get hasRating => rating != null && rating! > 0;

  /// Obtiene el texto descriptivo del tipo de relación
  String get relationshipLabel {
    switch (relationship) {
      case 'roommate':
        return 'Compañero de cuarto';
      case 'landlord':
        return 'Propietario anterior';
      case 'family':
        return 'Familiar';
      case 'friend':
        return 'Amigo';
      default:
        return relationship;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        refereeName,
        refereeEmail,
        refereePhone,
        relationship,
        comments,
        rating,
        verified,
        verificationCode,
        codeExpiresAt,
        createdAt,
        updatedAt,
      ];
}