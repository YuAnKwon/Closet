import 'package:flutter/material.dart';

class BodyTypeResult extends StatelessWidget {
  final String bodyType;
  final String description;
  final List<String> recommendedItems;
  final List<String> recommendedImages;
  final List<String> avoidItems;
  final List<String> avoidImages;

  const BodyTypeResult({
    Key? key,
    required this.bodyType,
    required this.description,
    required this.recommendedItems,
    required this.recommendedImages,
    required this.avoidItems,
    required this.avoidImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('체형 분류 결과'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '나의 체형은 ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '\'${bodyType}\'',
                        style: TextStyle(
                          fontSize: 27,
                          color: Color(0xFFAC9889),
                        ),
                      ),
                      TextSpan(
                        text: ' 입니다.',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFC7B3A3), width: 1.5),
                  ),
                  child: Image.asset(recommendedImages[0], width: 275),
                ),
              ),
              SizedBox(height: 30),
              Text(
                '${bodyType}이란?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                softWrap: true,
              ),
              SizedBox(height: 30),
              Container(
                height: 1,
                color: Colors.grey[400],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Image.asset(
                    'assets/body_type/star.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '이런 스타일을 추천해요',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Image.asset(
                    'assets/body_type/star.png',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                recommendedItems[0],
                style: TextStyle(fontSize: 16, color: Colors.grey[900]),
              ),
              SizedBox(height: 20),
              _buildImageRow(recommendedImages.sublist(1, 3)),
              SizedBox(height: 30),
              Text(
                recommendedItems[1],
                style: TextStyle(fontSize: 16, color: Colors.grey[900]),
              ),
              SizedBox(height: 10),
              _buildImageRow(recommendedImages.sublist(3, 5)),
              SizedBox(height: 30),
              Container(
                height: 1,
                color: Colors.grey[400],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Image.asset(
                    'assets/body_type/no_sign.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '피해야할 Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Image.asset(
                    'assets/body_type/no_sign.png',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                avoidItems[0],
                style: TextStyle(fontSize: 16, color: Colors.grey[900]),
              ),
              SizedBox(height: 10),
              _buildImageRow(avoidImages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageRow(List<String> images) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: images
          .map(
            (image) => Image.asset(
              image,
              width: 150,
            ),
          )
          .toList(),
    );
  }
}
