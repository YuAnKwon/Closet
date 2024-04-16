import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../api_resource/api_resource.dart';
import '../closet_mainscreen.dart';

class ClothUpload extends StatefulWidget {
  final Map<String, dynamic> responseData;

  const ClothUpload({Key? key, required this.responseData}) : super(key: key);

  @override
  State<ClothUpload> createState() => _ClothRegisterState();
}

class _ClothRegisterState extends State<ClothUpload> {
  File? _image;
  Uint8List? _imageBytes;
  String? _selectedCategory;
  TextEditingController _infoController = TextEditingController();

  List<String> categories = ['상의', '하의', '신발', '가방'];
  Map<String, List<String>> subCategories = {
    '상의': ['니트', '후드', '티셔츠', '맨투맨', '셔츠'],
    '하의': ['청바지', '슬랙스', '치마', '반바지'],
    '신발': ['운동화', '구두', '샌들', '슬리퍼'],
    '가방': ['백팩', '숄더백', '크로스백', '토트백'],
  };

  @override
  void initState() {
    super.initState();
    _getImageFromServer();
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  void _getImageFromServer() async {
    final Map<String, dynamic> data =
        widget.responseData; // responseData를 사용하여 데이터 가져오기
    String imageString = data['image'];
    Uint8List bytes = base64.decode(imageString);
    setState(() {
      _imageBytes = bytes;
    });
  }

  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories
          .map((category) => ElevatedButton(
                onPressed: () {
                  _saveSelectedCategory(category);
                },
                child: Text(category),
              ))
          .toList(),
    );
  }

  void _saveSelectedCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Widget _buildSubCategories() {
    if (_selectedCategory == null) {
      return SizedBox.shrink();
    }
    final subCategoryList = subCategories[_selectedCategory!] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '하위 카테고리 선택',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: subCategoryList
              .map((subCategory) => ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSubCategory = subCategory;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedSubCategory == subCategory
                          ? Color(0xDAD9FF) // 색상 코드
                          : null,
                    ),
                    child: Text(subCategory),
                  ))
              .toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String? _selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('옷장 등록'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              _buildPhotoArea(),
              SizedBox(height: 30),
              Text(
                '카테고리 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildCategoryButtons(),
              SizedBox(height: 20),
              _buildSubCategories(),
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
                controller: _infoController,
                decoration: InputDecoration(
                  hintText: '옷에 대한 정보를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 저장 버튼 눌렀을 때 실행될 코드
                    _saveClothInformation(_selectedSubCategory);
                  },
                  child: Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return Center(
      child: _imageBytes != null
          ? Container(
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            )
          : _image != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      '사진 불러오는 중...',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                )
              : Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey,
                  child: Center(
                    child: _imageBytes == null
                        ? Text(
                            '사진 불러오기에 실패했습니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        : CircularProgressIndicator(),
                  ),
                ),
    );
  }

  void _saveClothInformation(String? subCategory) {
    // TextFormField에서 텍스트 가져오기
    String info = _infoController.text;

    // 필요한 모든 데이터가 있는지 확인
    if (subCategory != null) {
      // 서버에 보낼 데이터 준비
      Map<String, dynamic> clothData = {
        'image': widget.responseData['filename'],
        'category': subCategory,
        'memo': info,
      };

      sendDataToServer(clothData);
    } else {
      // 카테고리가 선택되지 않은 경우 toast 표시
      Fluttertoast.showToast(
        msg: "카테고리를 선택해주세요",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }


  Future<void> sendDataToServer(Map<String, dynamic> data) async {
    try {
      // 서버 URL 설정
      String serverUrl =
          '${ApiResource.serverUrl}/closet/dbsave';

      // 데이터를 JSON 형식으로 인코딩
      String jsonData = json.encode(data);

      // HTTP POST 요청 보내기
      var response = await http.post(
        Uri.parse(serverUrl),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      // 응답 확인
      if (response.statusCode == 200) {
        print('전송한 데이터 입니다 !!!!!!!!!!!!!!!!!!!!${jsonData} ');

        Fluttertoast.showToast(
            msg: "성공적으로 등록되었습니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        // 서버가 성공적으로 응답한 경우
        print('데이터 전송 성공');
        // 다음 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClosetHomePage()), // 홈 페이지로 이동
        );
      } else {
        // 오류가 발생한 경우
        print('HTTP 오류: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 예외 처리
      print('오류 발생: $e');
    }
  }
}
