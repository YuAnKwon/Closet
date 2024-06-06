import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_resource/ApiResource.dart';
import 'body_result.dart';
import 'body_result_screen.dart';

class UploadBody extends StatefulWidget {
  @override
  _UploadBodyState createState() => _UploadBodyState();
}

class _UploadBodyState extends State<UploadBody> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  bool _loading = false;

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
            SizedBox(height: 30),
            _buildPhotoArea(),
            SizedBox(height: 20),
            Text(
              '자신의 체형이 잘 드러나는 사진을 \n 업로드 해주세요',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
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
              child: Text("사진 업로드"),
            ),
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
      child: Image.file(File(_image!.path)),
    )
        : Container(
      width: 300,
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/body_ex.png',
          )
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
            getImage(ImageSource.camera);
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery);
          },
          child: Text("갤러리"),
        ),
      ],
    );
  }

  void post_clothpic(String imagePath) async {
    setState(() {
      _loading = true;
    });
     var dio = Dio();
    try {
      dio.options.contentType = 'multipart/form-data';
      dio.options.maxRedirects.isFinite;

      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      var response = await dio.post(
        ApiResource.serverUrl + '/bodyupload',
        data: formData,
      );

      print('응답 데이터: ${response.data}');

      String bodyType = response.data['body_shape'];
      //String bodyType = '삼각형';
      BodyTypeData? bodyTypeData = getBodyTypeData(bodyType);
      if (bodyTypeData == null) {
        showAlertDialog(context, '알 수 없는 체형입니다.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BodyTypeResult(
            bodyType: bodyTypeData.bodyType,
            description: bodyTypeData.description,
            recommendedItems: bodyTypeData.recommendedItems,
            recommendedImages: bodyTypeData.recommendedImages,
            avoidItems: bodyTypeData.avoidItems,
            avoidImages: bodyTypeData.avoidImages,
          ),
        ),
      );
    } catch (e) {
      print('업로드 실패: $e');
      showAlertDialog(context, '이미지 업로드에 실패했습니다.');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

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
