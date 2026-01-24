/// Roles de usuario para personalizar la experiencia.
/// - tenant: Arrendatario (busca, filtra, guarda favoritos, aplica)
/// - landlord: Propietario (publica, gestiona)
/// - admin: Administración/moderación
enum UserRole { tenant, landlord, admin }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.tenant:
        return 'tenant';
      case UserRole.landlord:
        return 'landlord';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'landlord':
        return UserRole.landlord;
      case 'admin':
        return UserRole.admin;
      case 'tenant':
      default:
        return UserRole.tenant;
    }
  }
}
