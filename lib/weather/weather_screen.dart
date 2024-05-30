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

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  void _loadWeatherData() {
    getWeatherData(_onDataLoaded, _onError);
  }

  void _onDataLoaded(double temperature, String description, String icon) {
    setState(() {
      _temperature = temperature;
      _weatherDescription = description;
      _weatherIcon = icon;
      _isLoading = false;
    });
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
    List<String> topClothing = getTopClothingRecommendations(_temperature ?? 0);
    List<String> bottomClothing = getTopClothingRecommendations(_temperature ?? 0);
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
              padding: const EdgeInsets.all(20.0), // 여기에 패딩을 추가합니다
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
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
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            getClothingImage(clothing),
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
          SizedBox(height: 8),
          Text(
            clothing,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}