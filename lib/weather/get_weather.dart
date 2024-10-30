import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Future<void> getWeatherData(Function(double, String, String, double, double, int, double) onDataLoaded, Function(String) onError) async {
  Position position;
  try {
    position = await _determinePosition();
    String apiKey = '125aa18fbbae6d4c93f20fdd0279b39b';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=kr';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var weatherData = jsonDecode(response.body);
      double minTemp = (weatherData['main']['temp_min'] as num).toDouble();
      double maxTemp = (weatherData['main']['temp_max'] as num).toDouble();
      double temp = (weatherData['main']['temp'] as num).toDouble();
      double windSpeed = (weatherData['wind']['speed'] as num).toDouble();
      int humidity = weatherData['main']['humidity'];

      onDataLoaded(
          temp,
          weatherData['weather'][0]['description'],
          weatherData['weather'][0]['icon'],
          minTemp,
          maxTemp,
          humidity,
          windSpeed
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  } catch (e) {
    print(e);
    onError('위치 정보를 가져올 수 없습니다. \n 위치 서비스를 활성화하고 앱 권한을 허용해주세요.');
  }
}

Future<Position> _determinePosition() async {
  return await Geolocator.getCurrentPosition();
}
