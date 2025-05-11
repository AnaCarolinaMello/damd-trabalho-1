import 'package:damd_trabalho_1/services/Api.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/models/User.dart';

class UserController {
  static final path = 'users';
  static final databaseService = DatabaseService.instance;

  static Future<List<User>> getUsers() async {
    return await databaseService.getUsers();
  }

  static Future<User?> getUser(String email, String password) async {
  //   try {
  //     return await ApiService.post(path + '/login', {
  //       'email': email,
  //       'password': password,
  //     });
  //   } catch (e) {
      return await databaseService.login(email, password);
    // }
  }

  static Future createUser(User user) async {
    // try {
    //   await ApiService.post(path, user);
    // } catch (e) {
      await databaseService.createUser(user);
    // }
  }

  static Future updateUser(User user) async {
    // try {
    //   await ApiService.put(path + '/' + user.id!, user);
    // } catch (e) {
      await databaseService.updateUser(user);
    // }
  }
}