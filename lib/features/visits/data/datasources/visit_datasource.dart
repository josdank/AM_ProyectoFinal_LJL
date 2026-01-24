import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/visit_model.dart';

abstract class VisitDatasource {
  /// Obtiene todas las visitas del usuario (como visitante)
  Future<List<VisitModel>> getMyVisits(String userId);

  /// Obtiene visitas a mis propiedades (como dueño)
  Future<List<VisitModel>> getVisitsToMyListings(String ownerId);

  /// Obtiene una visita por ID
  Future<VisitModel> getVisit(String visitId);

  /// Crea una nueva visita
  Future<VisitModel> scheduleVisit(VisitModel visit);

  /// Confirma una visita (solo el dueño)
  Future<VisitModel> confirmVisit(String visitId);

  /// Cancela una visita
  Future<VisitModel> cancelVisit(String visitId);

  /// Marca una visita como completada
  Future<VisitModel> completeVisit(String visitId);

  /// Obtiene visitas por listing
  Future<List<VisitModel>> getVisitsByListing(String listingId);

  /// Obtiene horarios disponibles para un listing en una fecha
  Future<List<DateTime>> getAvailableSlots({
    required String listingId,
    required DateTime date,
    required int durationMinutes,
  });
}

class VisitDatasourceImpl implements VisitDatasource {
  final SupabaseClient client;

  VisitDatasourceImpl({required this.client});

  @override
  Future<List<VisitModel>> getMyVisits(String userId) async {
    try {
      final response = await client
          .from('visits')
          .select()
          .eq('visitor_id', userId)
          .order('scheduled_at', ascending: false);

      return (response as List)
          .map((json) => VisitModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al cargar visitas: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<VisitModel>> getVisitsToMyListings(String ownerId) async {
    try {
      final response = await client
          .from('visits')
          .select('''
            *,
            listings!inner(owner_id)
          ''')
          .eq('listings.owner_id', ownerId)
          .order('scheduled_at', ascending: false);

      return (response as List)
          .map((json) => VisitModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al cargar visitas: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<VisitModel> getVisit(String visitId) async {
    try {
      final response = await client
          .from('visits')
          .select()
          .eq('id', visitId)
          .single();

      return VisitModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const ServerException(message: 'Visita no encontrada');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<VisitModel> scheduleVisit(VisitModel visit) async {
    try {
      // Verificar que el horario esté disponible
      final existingVisits = await client
          .from('visits')
          .select()
          .eq('listing_id', visit.listingId)
          .gte('scheduled_at', visit.scheduledAt.toIso8601String())
          .lt('scheduled_at', visit.endTime.toIso8601String())
          .neq('status', 'cancelled');

      if ((existingVisits as List).isNotEmpty) {
        throw const ServerException(
          message: 'Este horario ya está ocupado',
        );
      }

      final data = visit.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data['status'] = 'pending';

      final response = await client
          .from('visits')
          .insert(data)
          .select()
          .single();

      return VisitModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al agendar visita: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<VisitModel> confirmVisit(String visitId) async {
    try {
      final response = await client
          .from('visits')
          .update({
            'status': 'confirmed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', visitId)
          .select()
          .single();

      return VisitModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al confirmar visita: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<VisitModel> cancelVisit(String visitId) async {
    try {
      final response = await client
          .from('visits')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', visitId)
          .select()
          .single();

      return VisitModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al cancelar visita: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<VisitModel> completeVisit(String visitId) async {
    try {
      final response = await client
          .from('visits')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', visitId)
          .select()
          .single();

      return VisitModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Error al completar visita: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<VisitModel>> getVisitsByListing(String listingId) async {
    try {
      final response = await client
          .from('visits')
          .select()
          .eq('listing_id', listingId)
          .neq('status', 'cancelled')
          .order('scheduled_at', ascending: true);

      return (response as List)
          .map((json) => VisitModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<DateTime>> getAvailableSlots({
    required String listingId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      // Horario de disponibilidad: 9:00 AM a 7:00 PM
      final startOfDay = DateTime(date.year, date.month, date.day, 9, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 19, 0);

      // Obtener visitas existentes del día
      final existingVisits = await getVisitsByListing(listingId);
      final dayVisits = existingVisits.where((visit) {
        return visit.scheduledAt.year == date.year &&
            visit.scheduledAt.month == date.month &&
            visit.scheduledAt.day == date.day;
      }).toList();

      // Generar slots cada 30 minutos
      final slots = <DateTime>[];
      var currentSlot = startOfDay;

      while (currentSlot.isBefore(endOfDay)) {
        final slotEnd = currentSlot.add(Duration(minutes: durationMinutes));

        // Verificar si el slot no se solapa con visitas existentes
        final isAvailable = !dayVisits.any((visit) {
          final visitEnd = visit.endTime;
          return (currentSlot.isBefore(visitEnd) &&
              slotEnd.isAfter(visit.scheduledAt));
        });

        if (isAvailable) {
          slots.add(currentSlot);
        }

        currentSlot = currentSlot.add(const Duration(minutes: 30));
      }

      return slots;
    } catch (e) {
      throw ServerException(
          message: 'Error al obtener horarios disponibles: $e');
    }
  }
}