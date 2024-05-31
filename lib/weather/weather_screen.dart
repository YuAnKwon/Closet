import 'dart:convert';
import 'package:closet/weather/weather_cloth.dart';
import 'package:flutter/material.dart';
import 'get_weather.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String? _weatherDescription;
  double? _temperature;
  String? _weatherIcon;
  bool _isLoading = true;

  final RecommendCloth recommendCloth = RecommendCloth();
  @override
  void initState() {
    super.initState();
    getWeatherData(_onDataLoaded, _onError);
  }

  // 날씨데이터
  void _onDataLoaded(double temperature, String description, String icon) {
    setState(() {
      _temperature = temperature;
      _weatherDescription = description;
      _weatherIcon = icon;
      _isLoading = false;

      // 날씨 데이터를 가져온 후에 옷 데이터
      _loadClothingImages();
    });
  }


  Future<void> _loadClothingImages() async {
    try {
      await recommendCloth.loadClothingImages();
      setState(() {});
    } catch (error) {
      _onError(error.toString());
    }
  }

  void _onError(String message) {
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> topClothing = recommendCloth.ClothRecommend(_temperature ?? 0);
    List<String> bottomClothing = recommendCloth.ClothRecommend(_temperature ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('날씨 코디 추천'),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_weatherIcon != null)
                      Image.network(
                        'http://openweathermap.org/img/wn/$_weatherIcon@2x.png',
                        width: 100,
                        height: 100,
                      ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          '${_temperature?.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 32),
                        ),
                        Text(
                          '$_weatherDescription',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                '오늘 날씨에 어울리는 옷 추천',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '상의',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildClothingBox(topClothing[0]),
                      SizedBox(width: 10),
                      if (topClothing.length > 1) _buildClothingBox(topClothing[1]),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '하의',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildClothingBox(bottomClothing[2]),
                      SizedBox(width: 10),
                      if (bottomClothing.length > 3) _buildClothingBox(bottomClothing[3]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingBox(String clothing) {
    String imageUrl = recommendCloth.getClothingImage(clothing);

    // 이미지가 base64 문자열인지 확인
    bool isBase64 = !imageUrl.startsWith('data:image') && !imageUrl.startsWith('assets');

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10),
        image: imageUrl.isNotEmpty && isBase64
            ? DecorationImage(
          image: MemoryImage(base64Decode(imageUrl)),
          fit: BoxFit.cover,
        )
            : imageUrl.isNotEmpty && !isBase64
            ? DecorationImage(
          image: AssetImage(imageUrl), // base64가 아닌 경우 이미지 경로를 사용
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: imageUrl.isEmpty
          ? Center(child: Text(clothing, textAlign: TextAlign.center))
          : null,
    );
  }

}
