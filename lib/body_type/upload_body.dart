import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../api_resource/ApiResource.dart';
import 'BodyType_Classifier.dart';

class UploadBody extends StatefulWidget {
  @override
  _UploadBodyState createState() => _UploadBodyState();
}

class _UploadBodyState extends State<UploadBody> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  bool _loading = false;

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(
      source: imageSource,
    );
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("나의 체형에 맞는 패션은?"),
          centerTitle: true,
          elevation: 1.0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            _buildButton(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  post_clothpic(_image!.path);
                } else {
                  print('이미지를 선택하세요.');
                }
              },
              child: Text("사진 등록"),
            ),
            // 로딩 표시
            if (_loading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      width: 300,
      height: 300,
      child: Image.file(File(_image!.path)), // 가져온 이미지를 화면에 띄워주는 코드
    )
        : Container(
      width: 300,
      height: 300,
      color: Colors.grey[400],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '자신의 체형이 잘 드러나는 사진을 \n 업로드 해주세요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera); // 카메라로 찍은 사진 가져오기
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); // 갤러리에서 사진 가져오기
          },
          child: Text("갤러리"),
        ),
      ],
    );
  }

  //----------------------사진 POST----------------------------
  void post_clothpic(String imagePath) async {
    setState(() {
      _loading = true; // Start loading state
    });
    var dio = Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      // Create FormData
      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      // Send POST request to the server
      var response = await dio.post(
        ApiResource.serverUrl + '/bodyupload',
        data: formData,
      );

      print('응답 데이터: ${response.data}');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BodyTypeClassifier(responseData: response.data)),
      );
    } catch (e) {
      // Handle exceptions and show alert if failed
      print('업로드 실패: $e');
        showAlertDialog(context, '이미지 업로드에 실패했습니다.');
    } finally {
      setState(() {
        _loading = false; // End loading state
      });
    }
  }


  // 알림 창 표시
  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("업로드 실패"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }
}

