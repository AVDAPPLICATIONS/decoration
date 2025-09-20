class MaterialModel {
  final int id;
  final String name;
  final String unit;
  final String? imageUrl;
  final String? notes;

  MaterialModel({
    required this.id,
    required this.name,
    required this.unit,
    this.imageUrl,
    this.notes,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      imageUrl: json['image_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'image_url': imageUrl,
      'notes': notes,
    };
  }
}
