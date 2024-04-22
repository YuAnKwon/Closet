import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_resource/ApiResource.dart';

Map<int, String> _imageCache = {}; // 이미지 캐시 맵
Future<List<Map<String, dynamic>>> getImagesFromServer(String selectedSubCategory) async {
  List<Map<String, dynamic>> images = [];

  try {
    final response = await http.get(
      Uri.parse('${ApiResource.serverUrl}/closet/$selectedSubCategory'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    final jsonData = jsonDecode(response.body);
    List<dynamic> imagesData = jsonData;

    for (var imageData in imagesData) {
      String imageString = imageData['image'];
      int clothNum = imageData['num'];
      if (!_imageCache.containsKey(clothNum)) {
        // 이미지가 캐시되어 있지 않다면 이미지를 캐시에 저장
        _imageCache[clothNum] = imageString;
      }
      images.add({'image': imageString, 'num': clothNum});
    }
    print(jsonData);

  } catch (error) {
    print('Error fetching images from server: $error');
  }

  return images;
}