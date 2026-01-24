class AppConstants {
  // ============================================
  // APP INFO
  // ============================================
  static const String appName = 'Busca Compañero';
  static const String appVersion = '1.0.0';
  
  // ============================================
  // LÍMITES DE ARCHIVOS
  // ============================================
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;
  
  // ============================================
  // FORMATO DE FECHAS
  // ============================================
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // ============================================
  // VALIDACIONES
  // ============================================
  static const int minPasswordLength = 6;
  static const int maxBioLength = 500;
  static const int minAge = 18;
  static const int maxPhoneLength = 10;
  
  // ============================================
  // COMPATIBILIDAD - SLEEP SCHEDULE
  // ============================================
  static const Map<String, String> sleepScheduleLabels = {
    'early_bird': '🌅 Madrugador',
    'night_owl': '🦉 Nocturno',
    'flexible': '⏰ Flexible',
  };
  
  static const Map<String, String> sleepScheduleDescriptions = {
    'early_bird': 'Duermo y despierto temprano',
    'night_owl': 'Duermo y despierto tarde',
    'flexible': 'Me adapto fácilmente',
  };
  
  // ============================================
  // COMPATIBILIDAD - CLEANING
  // ============================================
  static const Map<String, String> cleaningFrequencyLabels = {
    'daily': 'Diariamente',
    'weekly': 'Semanalmente',
    'as_needed': 'Cuando sea necesario',
  };
  
  static const List<String> cleanlinessLevelLabels = [
    'No me importa',
    'Poco',
    'Normal',
    'Bastante',
    'Muy ordenado',
  ];
  
  // ============================================
  // COMPATIBILIDAD - SOCIAL
  // ============================================
  static const Map<String, String> socialPreferenceLabels = {
    'very_social': '👥 Muy social',
    'moderate': '😊 Moderado',
    'private': '🤫 Privado',
  };
  
  static const Map<String, String> guestFrequencyLabels = {
    'frequently': 'Frecuentemente',
    'occasionally': 'Ocasionalmente',
    'rarely': 'Raramente',
    'never': 'Nunca',
  };
  
  // ============================================
  // COMPATIBILIDAD - WORK SCHEDULE
  // ============================================
  static const Map<String, String> workScheduleLabels = {
    'morning': '🌅 Mañana',
    'afternoon': '☀️ Tarde',
    'evening': '🌆 Noche',
    'night': '🌙 Madrugada',
    'flexible': '⏰ Flexible',
  };
  
  // ============================================
  // COMPATIBILIDAD - TEMPERATURE
  // ============================================
  static const Map<String, String> temperaturePreferenceLabels = {
    'cold': '❄️ Frío',
    'moderate': '🌡️ Moderado',
    'warm': '🔥 Calor',
  };
  
  // ============================================
  // COMPATIBILIDAD - SCORES
  // ============================================
  static const int compatibilityExcellent = 80;
  static const int compatibilityVeryGood = 65;
  static const int compatibilityGood = 50;
  static const int compatibilityRegular = 35;
  
  static const Map<String, String> compatibilityLevelLabels = {
    'excellent': 'Excelente',
    'very_good': 'Muy Buena',
    'good': 'Buena',
    'regular': 'Regular',
    'low': 'Baja',
  };
  
  // ============================================
  // GENDER OPTIONS
  // ============================================
  static const List<String> genderOptions = [
    'Masculino',
    'Femenino',
    'Otro',
    'Prefiero no decir',
  ];
  
  // ============================================
  // OCCUPATION OPTIONS
  // ============================================
  static const List<String> occupationOptions = [
    'Estudiante',
    'Profesional',
    'Ambos',
  ];
  
  // ============================================
  // NOISE TOLERANCE LABELS
  // ============================================
  static const List<String> noiseToleranceLabels = [
    'Muy sensible',
    'Sensible',
    'Normal',
    'Tolerante',
    'Muy tolerante',
  ];
  
  // ============================================
  // MUSIC VOLUME LABELS
  // ============================================
  static const List<String> musicVolumeLabels = [
    'Muy bajo',
    'Bajo',
    'Medio',
    'Alto',
    'Muy alto',
  ];
  
  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Obtiene el label de compatibilidad según el score
  static String getCompatibilityLabel(double score) {
    if (score >= compatibilityExcellent) return compatibilityLevelLabels['excellent']!;
    if (score >= compatibilityVeryGood) return compatibilityLevelLabels['very_good']!;
    if (score >= compatibilityGood) return compatibilityLevelLabels['good']!;
    if (score >= compatibilityRegular) return compatibilityLevelLabels['regular']!;
    return compatibilityLevelLabels['low']!;
  }
  
  /// Valida si la imagen cumple con los límites
  static bool isValidImageSize(int bytes) {
    return bytes <= maxImageSizeBytes;
  }
  
  /// Valida si la edad es válida
  static bool isValidAge(DateTime birthDate) {
    final age = DateTime.now().year - birthDate.year;
    return age >= minAge;
  }
} 