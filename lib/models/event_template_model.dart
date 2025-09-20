class EventTemplateModel {
  final int id;
  final String name;
  final DateTime createdAt;

  EventTemplateModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory EventTemplateModel.fromJson(Map<String, dynamic> json) {
    return EventTemplateModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
