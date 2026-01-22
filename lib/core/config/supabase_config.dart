import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // URLs de Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Deep Links para reset password y email verification
  static String get resetPasswordUrl => 
      dotenv.env['RESET_PASSWORD_URL'] ?? 'myapp://reset-password';
  
  static String get emailVerificationUrl =>
      dotenv.env['EMAIL_VERIFICATION_URL'] ?? 'myapp://verify-email';
  
  // Storage
  static const String profilePhotosBucket = 'profile-photos';
  static const String listingImagesBucket = 'listing-images';
  
  // Validaciones
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL no está configurada en .env');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY no está configurada en .env');
    }
  }
}