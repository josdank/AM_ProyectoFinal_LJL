import '../../features/compatibility/domain/entities/habits.dart';
import '../../features/compatibility/domain/entities/compatibility_score.dart';

class CompatibilityCalculator {
  /// Calcula el score de compatibilidad entre dos usuarios
  static CompatibilityScore calculate(Habits habits1, Habits habits2) {
    final Map<String, double> categoryScores = {};
    final List<String> strengths = [];
    final List<String> potentialIssues = [];

    // 1. Compatibilidad de Sueño (Peso: 20%)
    final sleepScore = _calculateSleepCompatibility(habits1, habits2);
    categoryScores['sleep'] = sleepScore;
    if (sleepScore >= 75) {
      strengths.add('Horarios de sueño compatibles');
    } else if (sleepScore < 50) {
      potentialIssues.add('Diferencias en horarios de sueño');
    }

    // 2. Limpieza y Orden (Peso: 25%)
    final cleanlinessScore = _calculateCleanlinessCompatibility(habits1, habits2);
    categoryScores['cleanliness'] = cleanlinessScore;
    if (cleanlinessScore >= 75) {
      strengths.add('Mismos estándares de limpieza');
    } else if (cleanlinessScore < 50) {
      potentialIssues.add('Diferentes estándares de limpieza');
    }

    // 3. Vida Social (Peso: 20%)
    final socialScore = _calculateSocialCompatibility(habits1, habits2);
    categoryScores['social'] = socialScore;
    if (socialScore >= 75) {
      strengths.add('Preferencias sociales compatibles');
    } else if (socialScore < 50) {
      potentialIssues.add('Diferentes preferencias sociales');
    }

    // 4. Estilo de Vida (Peso: 20%)
    final lifestyleScore = _calculateLifestyleCompatibility(habits1, habits2);
    categoryScores['lifestyle'] = lifestyleScore;
    if (lifestyleScore >= 75) {
      strengths.add('Estilos de vida compatibles');
    } else if (lifestyleScore < 50) {
      potentialIssues.add('Estilos de vida diferentes');
    }

    // 5. Horarios de Trabajo (Peso: 15%)
    final workScore = _calculateWorkCompatibility(habits1, habits2);
    categoryScores['work'] = workScore;
    if (workScore >= 75) {
      strengths.add('Horarios de trabajo compatibles');
    } else if (workScore < 50) {
      potentialIssues.add('Horarios de trabajo conflictivos');
    }

    // Calcular score general con pesos
    final overallScore = (sleepScore * 0.20) +
        (cleanlinessScore * 0.25) +
        (socialScore * 0.20) +
        (lifestyleScore * 0.20) +
        (workScore * 0.15);

    return CompatibilityScore(
      userId1: habits1.userId,
      userId2: habits2.userId,
      overallScore: overallScore,
      categoryScores: categoryScores,
      strengths: strengths,
      potentialIssues: potentialIssues,
    );
  }

  static double _calculateSleepCompatibility(Habits h1, Habits h2) {
    double score = 100.0;

    // Horarios de sueño
    final sleepScheduleMap = {
      'early_bird': 0,
      'flexible': 1,
      'night_owl': 2,
    };
    final diff = (sleepScheduleMap[h1.sleepSchedule]! - sleepScheduleMap[h2.sleepSchedule]!).abs();
    score -= diff * 25; // -25 puntos por cada nivel de diferencia

    // Tolerancia al ruido
    final noiseDiff = (h1.noiseToleranceLevel - h2.noiseToleranceLevel).abs();
    score -= noiseDiff * 5; // -5 puntos por cada nivel de diferencia

    return score.clamp(0, 100);
  }

  static double _calculateCleanlinessCompatibility(Habits h1, Habits h2) {
    double score = 100.0;

    // Nivel de limpieza (más importante)
    final cleanlinessDiff = (h1.cleanlinessLevel - h2.cleanlinessLevel).abs();
    score -= cleanlinessDiff * 15; // -15 puntos por cada nivel

    // Frecuencia de limpieza
    final frequencyMap = {
      'daily': 0,
      'weekly': 1,
      'as_needed': 2,
    };
    final freqDiff = (frequencyMap[h1.cleaningFrequency]! - frequencyMap[h2.cleaningFrequency]!).abs();
    score -= freqDiff * 10;

    return score.clamp(0, 100);
  }

  static double _calculateSocialCompatibility(Habits h1, Habits h2) {
    double score = 100.0;

    // Preferencia social
    final socialMap = {
      'very_social': 0,
      'moderate': 1,
      'private': 2,
    };
    final socialDiff = (socialMap[h1.socialPreference]! - socialMap[h2.socialPreference]!).abs();
    score -= socialDiff * 20;

    // Invitados
    if (h1.guestsAllowed != h2.guestsAllowed) {
      score -= 30; // Gran penalización si uno no permite invitados
    } else if (h1.guestsAllowed && h2.guestsAllowed) {
      final guestFreqMap = {
        'frequently': 0,
        'occasionally': 1,
        'rarely': 2,
        'never': 3,
      };
      final guestDiff = (guestFreqMap[h1.guestFrequency]! - guestFreqMap[h2.guestFrequency]!).abs();
      score -= guestDiff * 5;
    }

    // Volumen de música
    final volumeDiff = (h1.musicVolume - h2.musicVolume).abs();
    score -= volumeDiff * 5;

    return score.clamp(0, 100);
  }

  static double _calculateLifestyleCompatibility(Habits h1, Habits h2) {
    double score = 100.0;

    // Fumador (deal-breaker para muchos)
    if (h1.smoker != h2.smoker) {
      score -= 40;
    }

    // Bebedor
    if (h1.drinker != h2.drinker) {
      score -= 15;
    }

    // Mascotas
    if (h1.hasPets != h2.hasPets) {
      score -= 25;
    } else if (h1.hasPets && h2.hasPets && h1.petType != h2.petType) {
      score -= 10; // Diferentes tipos de mascotas
    }

    // Temperatura
    final tempMap = {
      'cold': 0,
      'moderate': 1,
      'warm': 2,
    };
    final tempDiff = (tempMap[h1.temperaturePreference]! - tempMap[h2.temperaturePreference]!).abs();
    score -= tempDiff * 10;

    return score.clamp(0, 100);
  }

  static double _calculateWorkCompatibility(Habits h1, Habits h2) {
    double score = 100.0;

    // Horario de trabajo
    final workMap = {
      'morning': 0,
      'afternoon': 1,
      'evening': 2,
      'night': 3,
      'flexible': 1,
    };
    final workDiff = (workMap[h1.workSchedule]! - workMap[h2.workSchedule]!).abs();
    score -= workDiff * 15;

    // Trabajo desde casa (bonus si ambos o ninguno)
    if (h1.worksFromHome == h2.worksFromHome) {
      score += 10;
    } else {
      score -= 20; // Uno trabaja desde casa y el otro no
    }

    return score.clamp(0, 100);
  }
}