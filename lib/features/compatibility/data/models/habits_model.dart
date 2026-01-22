import '../../domain/entities/habits.dart';

class HabitsModel extends Habits {
  const HabitsModel({
    required super.id,
    required super.userId,
    required super.sleepSchedule,
    required super.noiseToleranceLevel,
    required super.cleanlinessLevel,
    required super.cleaningFrequency,
    required super.socialPreference,
    required super.guestsAllowed,
    required super.guestFrequency,
    required super.smoker,
    required super.drinker,
    required super.hasPets,
    super.petType,
    required super.workSchedule,
    required super.worksFromHome,
    required super.sharedCommonAreas,
    required super.sharedKitchenware,
    required super.temperaturePreference,
    required super.hobbies,
    required super.musicVolume,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HabitsModel.fromJson(Map<String, dynamic> json) {
    return HabitsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sleepSchedule: json['sleep_schedule'] as String,
      noiseToleranceLevel: json['noise_tolerance_level'] as int,
      cleanlinessLevel: json['cleanliness_level'] as int,
      cleaningFrequency: json['cleaning_frequency'] as String,
      socialPreference: json['social_preference'] as String,
      guestsAllowed: json['guests_allowed'] as bool,
      guestFrequency: json['guest_frequency'] as String,
      smoker: json['smoker'] as bool,
      drinker: json['drinker'] as bool,
      hasPets: json['has_pets'] as bool,
      petType: json['pet_type'] as String?,
      workSchedule: json['work_schedule'] as String,
      worksFromHome: json['works_from_home'] as bool,
      sharedCommonAreas: json['shared_common_areas'] as bool,
      sharedKitchenware: json['shared_kitchenware'] as bool,
      temperaturePreference: json['temperature_preference'] as String,
      hobbies: json['hobbies'] != null 
          ? List<String>.from(json['hobbies'] as List)
          : [],
      musicVolume: json['music_volume'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ❌ ELIMINADO: if (id.isNotEmpty) 'id': id,
      // ✅ SIEMPRE incluir user_id (es la clave UNIQUE)
      'user_id': userId,
      'sleep_schedule': sleepSchedule,
      'noise_tolerance_level': noiseToleranceLevel,
      'cleanliness_level': cleanlinessLevel,
      'cleaning_frequency': cleaningFrequency,
      'social_preference': socialPreference,
      'guests_allowed': guestsAllowed,
      'guest_frequency': guestFrequency,
      'smoker': smoker,
      'drinker': drinker,
      'has_pets': hasPets,
      'pet_type': petType,
      'work_schedule': workSchedule,
      'works_from_home': worksFromHome,
      'shared_common_areas': sharedCommonAreas,
      'shared_kitchenware': sharedKitchenware,
      'temperature_preference': temperaturePreference,
      'hobbies': hobbies,
      'music_volume': musicVolume,
      // ✅ NO incluir created_at/updated_at - Supabase los maneja
    };
  }

  Habits toEntity() => Habits(
        id: id,
        userId: userId,
        sleepSchedule: sleepSchedule,
        noiseToleranceLevel: noiseToleranceLevel,
        cleanlinessLevel: cleanlinessLevel,
        cleaningFrequency: cleaningFrequency,
        socialPreference: socialPreference,
        guestsAllowed: guestsAllowed,
        guestFrequency: guestFrequency,
        smoker: smoker,
        drinker: drinker,
        hasPets: hasPets,
        petType: petType,
        workSchedule: workSchedule,
        worksFromHome: worksFromHome,
        sharedCommonAreas: sharedCommonAreas,
        sharedKitchenware: sharedKitchenware,
        temperaturePreference: temperaturePreference,
        hobbies: hobbies,
        musicVolume: musicVolume,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}