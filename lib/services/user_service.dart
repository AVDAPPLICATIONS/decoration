import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService api;

  UserService(this.api);

  Future<List<UserModel>> fetchUsers() async {
    final response = await api.get('/users');
    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    final response = await api.post('/users', body: payload);
    return UserModel.fromJson(response);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> payload) async {
    final response = await api.put('/users/$id', body: payload);
    return UserModel.fromJson(response);
  }

  Future<void> deleteUser(int id) async {
    await api.delete('/users/$id');
  }
}
