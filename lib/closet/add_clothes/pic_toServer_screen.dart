import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../api_resource/ApiResource.dart';
import 'cloth_upload_screen.dart';

class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화
  bool _loading = false; // 로딩 상태 변수 추가

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(
      source: imageSource,
      imageQuality: 30, // 이미지 크기 압축을 위해 퀄리티를 30으로 낮춤.
    );
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); // 가져온 이미지를 _image에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("옷 사진 등록"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
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

  // 버튼 위젯
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
            color: Colors.grey,
          );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera); // getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          child: Text("갤러리"),
        ),
      ],
    );
  }

  //----------------------사진 POST----------------------------
  void post_clothpic(String imagePath) async {
    setState(() {
      _loading = true; // 로딩 상태 시작
    });
    print("프로필 사진을 서버에 업로드 합니다.");
    var dio = new Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      // FormData 생성
      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      // 서버로 POST 요청 전송
      var response = await dio.post(
        ApiResource.serverUrl + '/closet/upload',
        data: formData,
      );

      // 서버로부터의 응답 확인
      print('성공적으로 업로드했습니다');
      print('응답 데이터: ${response.data}');

     // 이미지 업로드 후 다른 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClothUpload(responseData: response.data)),
      );
    } catch (e) {
      // 예외 처리 및 실패 시 알림 표시
      print('오류 발생: $e');
      showAlertDialog(context);
    } finally {
      setState(() {
        _loading = false; // 로딩 상태 종료
      });
    }
  }

  // 알림 창 표시
  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("업로드 실패"),
          content: Text("사진을 업로드하는 도중 오류가 발생했습니다."),
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
