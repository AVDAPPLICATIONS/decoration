import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'api_provider.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final api = ref.read(apiServiceProvider);
  return UserService(api);
});

final userProvider = StateNotifierProvider<UserNotifier, List<UserModel>>((ref) {
  final service = ref.read(userServiceProvider);
  return UserNotifier(ref, service);
});

class UserNotifier extends StateNotifier<List<UserModel>> {
  final Ref ref;
  final UserService service;

  UserNotifier(this.ref, this.service) : super([]);

  Future<void> fetchUsers() async {
    try {
      final users = await service.fetchUsers();
      state = users;
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> addUser(Map<String, dynamic> userPayload) async {
    try {
      await service.createUser(userPayload);
      await fetchUsers();
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> userPayload) async {
    try {
      await service.updateUser(id, userPayload);
      await fetchUsers();
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await service.deleteUser(id);
      state = state.where((u) => u.id != id).toList();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
