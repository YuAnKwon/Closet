import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../api_resource/ApiResource.dart';
import '../../res/Categories.dart';
import 'category_buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  List<String> categories = Categories.categories;
  Map<String, List<String>> subCategories = Categories.subCategories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImageFromServer();
    });
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  String mapEnglishCategoryToKorean(String englishCategory) {
    switch (englishCategory) {
      case 't-shirt':
        return '티셔츠';
      case 'hoodie':
        return '후드';
      case 'shirt':
        return '셔츠';
      case 'neat':
        return '니트';
      case 'mantoman':
        return '맨투맨';
      case 'jacket':
        return '자켓';
      case 'jeans':
        return '청바지';
      case 'skirt':
        return '치마';
      case 'short':
        return '반바지';
      case 'training_pants':
        return '트레이닝 바지';
      case 'backpack':
        return '백팩';
      case 'crossbag':
        return '크로스백';
      case 'bucketbag':
        return '버킷백';
      case 'running_shoes':
        return '운동화';
      case 'dress_shoes':
        return '구두';
      case 'sandal':
        return '샌들';
      case 'boots':
        return '부츠';
      default:
        return '기타';
    }
  }

  void _getImageFromServer() async {
    final Map<String, dynamic> data = widget.responseData;
    String imageString = data['image'];
    String subCategory = data['category'];
    Uint8List bytes = base64.decode(imageString);
    subCategory = mapEnglishCategoryToKorean(subCategory);
    setState(() {
      _imageBytes = bytes;
    });
    print(subCategory);
    _categoryYesOrNo(subCategory);
  }

  void _categoryYesOrNo(String subCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카테고리 확인'),
          content: Text('이 옷은 $subCategory 맞습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _autoCheckCategory(subCategory);
              },
              child: Text('YES'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('NO'),
            ),
          ],
        );
      },
    );
  }

  void _autoCheckCategory(String subCategory) {
    String? category;
    for (var entry in subCategories.entries) {
      if (entry.value.contains(subCategory)) {
        category = entry.key;
        break;
      }
    }

    if (category != null) {
      setState(() {
        _selectedCategory = category;
        _selectedSubCategory = subCategory;
      });
    }
  }

  String? _selectedSubCategory;

  void _saveSelectedCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('옷장 등록'),
        centerTitle: true,
        elevation: 10,
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
              CategorySubCategoryWidgets(
                categories: categories,
                subCategories: subCategories,
                onCategorySelected: _saveSelectedCategory,
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
                'MEMO',
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
          LoadingAnimationWidget.staggeredDotsWave(
            color: Color(0xFFC7B3A3),
            size: 50.0,
          ),
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
              : LoadingAnimationWidget.staggeredDotsWave(
            color: Color(0xFFC7B3A3),
            size: 50.0,
          ),
        ),
      ),
    );
  }

  void _saveClothInformation(String? subCategory) {
    String info = _infoController.text;

    if (subCategory != null) {
      Map<String, dynamic> clothData = {
        'image': widget.responseData['filename'],
        'category': subCategory,
        'memo': info,
      };
      print(widget.responseData['filename']);
      sendDataToServer(clothData);
    } else {
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
      String serverUrl = '${ApiResource.serverUrl}/closet/dbsave';
      String jsonData = json.encode(data);

      var response = await http.post(
        Uri.parse(serverUrl),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('전송한 데이터 입니다 !!!!!!!!!!!!!!!!!!!!${jsonData} ');

        Fluttertoast.showToast(
          msg: "성공적으로 등록되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );
        print('데이터 전송 성공');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        print('HTTP 오류: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }
}
