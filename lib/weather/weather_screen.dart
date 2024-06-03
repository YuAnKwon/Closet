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
  double? _minTemperature;
  double? _maxTemperature;
  int? _humidity;
  int? _precipProbability;

  bool _isLoading = true;
  String? _errorMessage;
  int _pageNumber = 2;

  final RecommendCloth recommendCloth = RecommendCloth();
  final Map<String, String> _clothingImages = {};

  @override
  void initState() {
    super.initState();
    getWeatherData(_onDataLoaded, _onError);
  }

  // 날씨데이터
  void _onDataLoaded(double temperature, String description, String icon,
      double minTemp, double maxTemp, int humidity, int? precipProbability) {
    setState(() {
      _temperature = temperature;
      _weatherDescription = description;
      _weatherIcon = icon;
      _minTemperature = minTemp;
      _maxTemperature = maxTemp;
      _humidity = humidity;
      _precipProbability = precipProbability;
      _isLoading = false;

      // 날씨 데이터를 가져온 후에 옷 데이터
      _loadClothingImages();
    });
  }

  Future<void> _loadClothingImages() async {
    try {
      List<String> clothingItems =
          recommendCloth.ClothRecommend(_temperature ?? 0);
      await recommendCloth.loadClothingImages(clothingItems);
      setState(() {});
    } catch (error) {
      _onError(error.toString());
    }
  }

  void _onError(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> topClothing = recommendCloth.ClothRecommend(_temperature ?? 0);
    List<String> bottomClothing =
        recommendCloth.ClothRecommend(_temperature ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('날씨 코디 추천'),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // SingleChildScrollView 추가
              child: Padding(
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_weatherIcon != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'http://openweathermap.org/img/wn/$_weatherIcon@2x.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '최저: ${_minTemperature?.toStringAsFixed(1)}°C',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 30),
                                Text(
                                  '최고: ${_maxTemperature?.toStringAsFixed(1)}°C',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '습도: $_humidity%',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 30),
                                Text(
                                  '강수확률: $_precipProbability%',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '상의',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildClothingBox(topClothing[0]),
                                SizedBox(width: 10),
                                if (topClothing.length > 1)
                                  _buildClothingBox(topClothing[1]),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              '하의',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildClothingBox(bottomClothing[2]),
                                SizedBox(width: 10),
                                if (bottomClothing.length > 3)
                                  _buildClothingBox(bottomClothing[3]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/bottom_icon/lookbook.png"),
              size: 24,
            ),
            label: 'Look Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/bottom_icon/recommend.png"),
              size: 24,
            ),
            label: '코디 추천',
          ),
        ],
        currentIndex: _pageNumber,
        selectedItemColor: Color(0xFFC7B3A3),
        elevation: 10,
        onTap: (index) {
          setState(() {
            _pageNumber = index;
          });
          if (_pageNumber == 0) {
            Navigator.pushReplacementNamed(context, '/lookbook');
          }
          if (_pageNumber == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
    );
  }

  Widget _buildClothingBox(String clothing) {
    String localImageUrl = recommendCloth.getClothingImage(clothing);
    String serverImageUrl = _clothingImages[clothing] ?? '';

    // 이미지가 base64 문자열인지 확인
    bool isLocalBase64 = !localImageUrl.startsWith('assets');
    bool isServerBase64 =
        serverImageUrl.isNotEmpty && serverImageUrl.startsWith('data:image');

    return Container(
      width: 130,
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: isServerBase64
                ? Image.memory(
                    base64Decode(serverImageUrl),
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(10),
                      image: localImageUrl.isNotEmpty && isLocalBase64
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(localImageUrl)),
                              fit: BoxFit.cover,
                            )
                          : localImageUrl.isNotEmpty && !isLocalBase64
                              ? DecorationImage(
                                  image: AssetImage(localImageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: localImageUrl.isNotEmpty ? null
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
          ),
          SizedBox(height: 5), // 텍스트와 이미지 사이 간격 조정
          Text(
            clothing,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
