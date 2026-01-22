import 'package:equatable/equatable.dart';

class Habits extends Equatable {
  final String id;
  final String userId;
  
  // Hábitos de sueño
  final String sleepSchedule; // 'early_bird', 'night_owl', 'flexible'
  final int noiseToleranceLevel; // 1-5
  
  // Limpieza y organización
  final int cleanlinessLevel; // 1-5
  final String cleaningFrequency; // 'daily', 'weekly', 'as_needed'
  
  // Social
  final String socialPreference; // 'very_social', 'moderate', 'private'
  final bool guestsAllowed;
  final String guestFrequency; // 'frequently', 'occasionally', 'rarely', 'never'
  
  // Estilo de vida
  final bool smoker;
  final bool drinker;
  final bool hasPets;
  final String? petType;
  
  // Trabajo/Estudio
  final String workSchedule; // 'morning', 'afternoon', 'evening', 'night', 'flexible'
  final bool worksFromHome;
  
  // Preferencias de vivienda
  final bool sharedCommonAreas;
  final bool sharedKitchenware;
  final String temperaturePreference; // 'cold', 'moderate', 'warm'
  
  // Entretenimiento
  final List<String> hobbies;
  final int musicVolume; // 1-5
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habits({
    required this.id,
    required this.userId,
    required this.sleepSchedule,
    required this.noiseToleranceLevel,
    required this.cleanlinessLevel,
    required this.cleaningFrequency,
    required this.socialPreference,
    required this.guestsAllowed,
    required this.guestFrequency,
    required this.smoker,
    required this.drinker,
    required this.hasPets,
    this.petType,
    required this.workSchedule,
    required this.worksFromHome,
    required this.sharedCommonAreas,
    required this.sharedKitchenware,
    required this.temperaturePreference,
    required this.hobbies,
    required this.musicVolume,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        sleepSchedule,
        noiseToleranceLevel,
        cleanlinessLevel,
        cleaningFrequency,
        socialPreference,
        guestsAllowed,
        guestFrequency,
        smoker,
        drinker,
        hasPets,
        petType,
        workSchedule,
        worksFromHome,
        sharedCommonAreas,
        sharedKitchenware,
        temperaturePreference,
        hobbies,
        musicVolume,
        createdAt,
        updatedAt,
      ];
}