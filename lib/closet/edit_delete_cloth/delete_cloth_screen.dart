import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:closet/api_resource/ApiResource.dart';

class ClothDelete{
  static Future<void> deleteCloth(BuildContext context, int clothNum) async {
    try {
      final Map<String, dynamic> clothData = {'num': clothNum};

      final http.Response response = await http.post(
        Uri.parse('${ApiResource.serverUrl}/closet/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode(clothData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "성공적으로 삭제되었습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
        // 삭제 성공 후 홈 화면으로 이동
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        print('HTTP 오류: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }
}
