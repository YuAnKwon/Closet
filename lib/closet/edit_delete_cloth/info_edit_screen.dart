import 'dart:convert';
import 'package:closet/api_resource/ApiResource.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Categories.dart';
import '../add_clothes/category_buttons.dart';
import 'delete_cloth_screen.dart';

import 'package:fluttertoast/fluttertoast.dart';

class ClothDetailPage extends StatefulWidget {
  final String image;
  final int clothNum;
  final String? category;
  final String? subcategory;

  const ClothDetailPage({
    Key? key,
    required this.image,
    required this.clothNum,
    this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  _ClothDetailPageState createState() => _ClothDetailPageState();
}

class _ClothDetailPageState extends State<ClothDetailPage> {
  late TextEditingController _memoController;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _memo;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: _memo);
    _selectedCategory = widget.category;
    _selectedSubCategory = widget.subcategory; // 상위 카테고리로 초기화
    _fetchClothDetail();
  }

  Future<void> _fetchClothDetail() async {
    final String url = '${ApiResource.serverUrl}/closet/giveinfo';

    try {
      final Map<String, dynamic> postData = {'num': widget.clothNum};

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
          _memo = memoText;
          _memoController.text = _memo!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('옷 수정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Center(
                child: Image.memory(
                  base64.decode(widget.image),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              Text(
                '카테고리 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              CategorySubCategoryWidgets(
                categories: Categories.categories,
                subCategories: Categories.subCategories,
                onCategorySelected: (String category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                onSubCategorySelected: (String subCategory) {
                  setState(() {
                    _selectedSubCategory = subCategory;
                  });
                },
                selectedCategory: _selectedCategory,
                selectedSubCategory: _selectedSubCategory,
              ),
              SizedBox(height: 20),
              Text(
                '정보란',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _memoController,
                decoration: InputDecoration(
                  hintText: '옷에 대한 정보를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _selectedSubCategory != null
                        ? _editinfo
                        : null, // 선택된 카테고리가 없을 때 버튼 비활성화
                    child: Text('수정'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      ClothDelete.deleteCloth(context, widget.clothNum);
                    },
                    child: Text('삭제'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editinfo() async {
    String memo = _memoController.text;
    try {
      final Map<String, dynamic> clothData = {
        'num': widget.clothNum,
        'category': _selectedSubCategory,
        'memo': memo,
      };

      final http.Response response = await http.post(
        Uri.parse('${ApiResource.serverUrl}/closet/modify'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode(clothData),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "성공적으로 수정되었습니다",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        // 서버가 성공적으로 응답한 경우
        print('데이터 전송 성공');
        // 다음 화면으로 이동
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // 오류가 발생한 경우
        print('HTTP 오류: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 예외 처리
      print('오류 발생: $e');
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }
}
