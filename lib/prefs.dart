import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? instance;

  static Future<void> init() async {
    instance ??= await SharedPreferences.getInstance();
  }
}
