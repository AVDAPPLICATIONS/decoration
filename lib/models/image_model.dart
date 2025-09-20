class ImageModel {
  final String id;
  final String url;
  final String description;

  ImageModel({
    required this.id,
    required this.url,
    required this.description,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
    };
  }
}