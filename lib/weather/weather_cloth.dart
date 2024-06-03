import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../api_resource/ApiResource.dart';

class RecommendCloth {
  final Map<String, String> _clothingImages = {};

  Future<void> loadClothingImages(List<String> clothingItems) async {
    for (String category in clothingItems) {
      try {
        final response = await http.get(
          Uri.parse('${ApiResource.serverUrl}/weather/$category'),
          headers: {'ngrok-skip-browser-warning': 'true'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final base64Image = data['image'];
          _clothingImages[category] = base64Image;
        } else {
          throw Exception('Failed to load clothing image for $category');
        }
      } catch (error) {
        print('Error loading image for $category: $error');
      }
    }
  }

  List<String> ClothRecommend(double temperature) {
    if (temperature >= 28) {
      return ['티셔츠', '민소매', '반바지', '치마'];
    } else if (temperature >= 23) {
      return ['티셔츠', '셔츠', '반바지', '슬랙스'];
    } else if (temperature >= 20) {
      return ['셔츠', '후드', '면바지', '청바지'];
    } else if (temperature >= 17) {
      return ['후드', '맨투맨', '트레이닝 바지', '청바지'];
    } else if (temperature >= 12) {
      return ['자켓', '니트', '청바지', '면바지'];
    } else if (temperature >= 9) {
      return ['트랜치코트', '자켓', '청바지', '면바지'];
    } else if (temperature >= 5) {
      return ['코트', '니트', '청바지', '기모바지'];
    } else {
      return ['패딩', '롱패딩', '기모바지', '청바지'];
    }
  }

  String getClothingImage(String clothing) {
    Random random = Random();
    int choice = random.nextInt(2) + 1;

    switch (clothing) {
      case '티셔츠':
      case '셔츠':
      case '후드':
      case '맨투맨':
      case '자켓':
      case '니트':
      case '반바지':
      case '청바지':
      case '치마':
      case '트레이닝 바지':
        return _clothingImages[clothing] ?? '';
      case '민소매':
        return 'assets/weathercloth/민소매${choice}.png';
      case '슬랙스':
        return 'assets/weathercloth/슬랙스${choice}.png';
      case '면바지':
        return 'assets/weathercloth/면바지${choice}.png';
      case '트랜치코트':
        return 'assets/weathercloth/트랜치코트${choice}.png';
      case '코트':
        return 'assets/weathercloth/코트${choice}.png';
      case '기모바지':
        return 'assets/weathercloth/기모바지${choice}.png';
      case '패딩':
        return 'assets/weathercloth/패딩${choice}.png';
      case '롱패딩':
        return 'assets/weathercloth/롱패딩${choice}.png';
      default:
        return '';
    }
  }
}
