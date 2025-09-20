class ToolModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String? notes;

  ToolModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.notes,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'notes': notes,
    };
  }
}
