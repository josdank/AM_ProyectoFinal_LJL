import '../../domain/entities/visit.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.listingId,
    required super.visitorId,
    required super.scheduledAt,
    super.durationMinutes,
    required super.status,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      visitorId: json['visitor_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'visitor_id': visitorId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Visit toEntity() => Visit(
        id: id,
        listingId: listingId,
        visitorId: visitorId,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        status: status,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}