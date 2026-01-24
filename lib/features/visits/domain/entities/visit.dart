import 'package:equatable/equatable.dart';

/// Entidad que representa una visita agendada a una propiedad
class Visit extends Equatable {
  final String id;
  final String listingId;
  final String visitorId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Visit({
    required this.id,
    required this.listingId,
    required this.visitorId,
    required this.scheduledAt,
    this.durationMinutes = 30,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si la visita está pendiente
  bool get isPending => status == 'pending';

  /// Verifica si la visita está confirmada
  bool get isConfirmed => status == 'confirmed';

  /// Verifica si la visita está completada
  bool get isCompleted => status == 'completed';

  /// Verifica si la visita está cancelada
  bool get isCancelled => status == 'cancelled';

  /// Verifica si la visita ya pasó
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  /// Verifica si la visita es hoy
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  /// Hora de fin de la visita
  DateTime get endTime =>
      scheduledAt.add(Duration(minutes: durationMinutes));

  /// Copia la visita con nuevos valores
  Visit copyWith({
    String? status,
    String? notes,
    DateTime? scheduledAt,
    int? durationMinutes,
  }) {
    return Visit(
      id: id,
      listingId: listingId,
      visitorId: visitorId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        listingId,
        visitorId,
        scheduledAt,
        durationMinutes,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}