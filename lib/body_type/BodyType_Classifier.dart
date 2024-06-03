import 'package:flutter/material.dart';

class BodyTypeClassifier extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const BodyTypeClassifier({Key? key, required this.responseData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('체형 분류 결과'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '체형 분석 결과',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '당신의 체형은 ${responseData['type']}형으로 아래와 같은 패션을 추천드립니다.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
