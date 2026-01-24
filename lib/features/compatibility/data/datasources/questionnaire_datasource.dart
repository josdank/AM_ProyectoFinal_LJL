import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/habits_model.dart';

abstract class QuestionnaireDatasource {
  Future<HabitsModel> getUserHabits(String userId);
  Future<HabitsModel> saveHabits(HabitsModel habits);
  Future<List<HabitsModel>> getAllHabits();
}

class QuestionnaireDatasourceImpl implements QuestionnaireDatasource {
  final SupabaseClient client;

  QuestionnaireDatasourceImpl({required this.client});

  @override
  Future<HabitsModel> getUserHabits(String userId) async {
    try {
      final response = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .single();

      return HabitsModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const ServerException(
          message: 'Usuario no ha completado el cuestionario',
        );
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener hábitos: $e');
    }
  }

  @override
  Future<HabitsModel> saveHabits(HabitsModel habits) async {
    try {
      final data = habits.toJson();
      
      // Asegurar que user_id esté presente
      data['user_id'] = habits.userId;
      
      // NO incluir timestamps - Supabase los maneja automáticamente
      data.remove('created_at');
      data.remove('updated_at');
      
      // NO incluir id - Supabase lo genera
      data.remove('id');

      // Upsert: inserta si no existe, actualiza si existe (basado en user_id UNIQUE)
      final response = await client
          .from('habits')
          .upsert(
            data,
            onConflict: 'user_id',  // Clave UNIQUE
          )
          .select()
          .single();

      return HabitsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error de base de datos: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error al guardar hábitos: $e');
    }
  }

  @override
  Future<List<HabitsModel>> getAllHabits() async {
    try {
      final response = await client
          .from('habits')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HabitsModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error al obtener hábitos: $e');
    }
  }
}