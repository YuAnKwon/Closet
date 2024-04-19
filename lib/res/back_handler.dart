import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BackButtonHandler {
  static DateTime? currentBackPressTime;

  static Future<bool> onWillPop() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      final msg = "앱을 종료하려면 한 번 더 누르세요";

      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    }

    return Future.value(true);
  }
}
