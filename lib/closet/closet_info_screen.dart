import 'dart:convert';
import 'package:closet/api_resource/ApiResource.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClothDetailPage extends StatefulWidget {
  final String image;
  final int clothNum;

  const ClothDetailPage({Key? key, required this.image, required this.clothNum}) : super(key: key);

  @override
  _ClothDetailPageState createState() => _ClothDetailPageState();
}

class _ClothDetailPageState extends State<ClothDetailPage> {
  String? memo;

  @override
  void initState() {
    super.initState();
    postClothNum(widget.clothNum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              base64.decode(widget.image),
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Memo: ${memo ?? '로딩 중...'}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> postClothNum(int clothNum) async {
    const String url = '${ApiResource.serverUrl}/closet/giveinfo';

    try {
      final Map<String, dynamic> postData = {'num': clothNum};

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode(postData),
      );

      print('응답 데이터: ${response.body}'); // 응답 데이터 출력

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> memoList = responseData['memo'];
        final Map<String, dynamic> memoMap = memoList.first;
        final String memoText = memoMap['memo'];
        setState(() {
          memo = memoText;
        });
      } else {
        print('ClothNum 전송에 실패했습니다. 에러 코드: ${response.statusCode}');
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print('에러 메시지: ${errorData['error']}');
      }
    } catch (error) {
      print('ClothNum 전송 중 에러가 발생했습니다: $error');
    }
  }


}
