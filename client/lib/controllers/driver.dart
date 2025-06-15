import 'package:damd_trabalho_1/models/Driver.dart';
import 'package:damd_trabalho_1/services/Database.dart';

class DriverController {
  static final path = 'drivers';
  static final databaseService = DatabaseService.instance;


  static Future<Driver?> getDriver(int id) async {
    return await databaseService.getDriver(id);
  }
}
