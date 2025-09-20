import '../models/issuance_model.dart';
import 'api_service.dart';

class IssuanceService {
  final ApiService api;

  IssuanceService(this.api);

  Future<List<IssuanceModel>> fetchIssuances({int? eventId}) async {
    final endpoint = eventId != null ? '/issuances/event/$eventId' : '/issuances';
    final response = await api.get(endpoint);
    return (response as List).map((json) => IssuanceModel.fromJson(json)).toList();
  }

  Future<IssuanceModel> createIssuance(IssuanceModel issuance) async {
    final response = await api.post('/issuances', body: issuance.toJson());
    return IssuanceModel.fromJson(response);
  }

  Future<void> deleteIssuance(int id) async {
    await api.delete('/issuances/$id');
  }
}
