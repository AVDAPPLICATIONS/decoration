class CostModel {
  final int id;
  final int eventId;
  final String description;
  final double amount;
  final DateTime date;

  CostModel({
    required this.id,
    required this.eventId,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory CostModel.fromJson(Map<String, dynamic> json) {
    return CostModel(
      id: json['id'],
      eventId: json['event_id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
