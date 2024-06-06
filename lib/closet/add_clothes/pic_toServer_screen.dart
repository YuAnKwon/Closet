import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("옷 사진 등록"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            _buildPhotoArea(),
            SizedBox(height: 30),
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
              child: Text("사진 업로드"),
            ),

            // 로딩 표시
            if (_loading)
              LoadingAnimationWidget.staggeredDotsWave(
                color: Color(0xFFC7B3A3),
                size: 50.0,
              ),
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
            child:
            Center(
              child: Text(
                '옷장에 등록할 옷을 \n 업로드 해주세요',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
        ApiResource.serverUrl + '/closet/upload',
        data: formData,
      );

      // Check response from the server
      print('응답 데이터: ${response.data}');

      // Navigate to another page after uploading the image
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClothUpload(responseData: response.data)),
      );
    } catch (e) {
      // Handle exceptions and show alert if failed
      print('업로드 실패: $e');
      if (e is DioError &&
          e.response != null &&
          e.response!.statusCode == 400 &&
          e.response!.data['error'] == 'Image already exists in the database') {
        showAlertDialog(context, '동일한 이미지가 이미 등록되었습니다.');
      } else {
        showAlertDialog(context, '이미지 업로드에 실패했습니다.');
      }
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
