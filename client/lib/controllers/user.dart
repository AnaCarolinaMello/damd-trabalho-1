import 'package:damd_trabalho_1/services/Api.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/models/User.dart';

class UserController {
  static final path = 'auth';
  static final databaseService = DatabaseService.instance;

  static Future<List<User>> getUsers() async {
    return await databaseService.getUsers();
  }

  static Future<User?> getUser(String email, String password) async {
    try {
      final response = await ApiService.post('$path/login', {
        'email': email,
        'password': password,
      });
      print('response: $response');
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('error  getUser: $e');
      return await databaseService.login(email, password);
    }
  }

  static Future<User?> getUserById(int id) async {
    try {
      final response = await ApiService.get('$path/$id');
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return await databaseService.getUser(id);
    }
  }

  static Future<User?> createUser(User user) async {
    try {
      final response = await ApiService.post(path, user);
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return await databaseService.createUser(user);
    }
  }

  static Future updateUser(User user) async {
    try {
      await ApiService.put('$path/${user.id!}', user);
    } catch (e) {
      await databaseService.updateUser(user);
    }
  }
}