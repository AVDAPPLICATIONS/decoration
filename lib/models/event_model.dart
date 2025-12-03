class EventModel {
  final int? id;
  final int? templateId;
  final int? yearId;
  final DateTime? date;
  final String? location;
  final String? description;
  final String? coverImage;
  final DateTime? createdAt;
  final String? name;
  final String? status;

  EventModel({
    this.id,
    this.templateId,
    this.yearId,
    this.date,
    this.location,
    this.description,
    this.coverImage,
    this.createdAt,
    this.name,
    this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      templateId: json['template_id'],
      yearId: json['year_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      location: json['location'],
      description: json['description'],
      coverImage: json['cover_image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'year_id': yearId,
      'date': date?.toIso8601String(),
      'location': location,
      'description': description,
      'cover_image': coverImage,
      'name': name,
      'status': status,
    };
  }
}
