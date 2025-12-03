import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  final String apiUrl;

  ImageUploadService(this.apiUrl);

  Future<void> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }
}
