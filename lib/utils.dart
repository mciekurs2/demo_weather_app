import 'package:flutter/material.dart';

class Utils {
  static String iconUrl(String? iconId) {
    return 'http://openweathermap.org/img/wn/$iconId@2x.png';
  }

  static showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
