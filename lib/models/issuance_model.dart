class IssuanceModel {
  final int id;
  final int eventId;
  final int materialId;
  final double quantityIssued;
  final String? notes;
  final DateTime issuedAt;

  IssuanceModel({
    required this.id,
    required this.eventId,
    required this.materialId,
    required this.quantityIssued,
    this.notes,
    required this.issuedAt,
  });

  factory IssuanceModel.fromJson(Map<String, dynamic> json) {
    return IssuanceModel(
      id: json['id'],
      eventId: json['event_id'],
      materialId: json['material_id'],
      quantityIssued: (json['quantity_issued'] as num).toDouble(),
      notes: json['notes'],
      issuedAt: DateTime.parse(json['issued_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'material_id': materialId,
      'quantity_issued': quantityIssued,
      'notes': notes,
    };
  }
}
