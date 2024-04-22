import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_resource/ApiResource.dart';

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
      images.add({'image': imageString, 'num': clothNum});
    }
    print(jsonData);
  } catch (error) {
    print('Error fetching images from server: $error');
  }

  return images;
}