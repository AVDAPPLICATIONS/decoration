class YearModel {
  final int id;
  final String yearName;
  final int templateId;
  final DateTime createdAt;
  final String? templateName;

  YearModel({
    required this.id,
    required this.yearName,
    required this.templateId,
    required this.createdAt,
    this.templateName,
  });

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      id: json['id'],
      yearName: json['year_name'],
      templateId: json['event_template_id'] ?? json['template_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      templateName: json['template_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year_name': yearName,
      'event_template_id': templateId,
    };
  }
}
