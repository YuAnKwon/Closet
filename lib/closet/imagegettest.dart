import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_resource/ApiResource.dart';

class ClosetPage extends StatefulWidget {
  @override
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  Uint8List _imageBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    _getImageFromServer();
  }

  void _getImageFromServer() async {
    try {
      final response = await http.get(Uri.parse('${ApiResource.serverUrl}/closet/후드'), headers: {'ngrok-skip-browser-warning':'true'});
      final jsonData = jsonDecode(response.body);
      String imageString = jsonData['image'];
      Uint8List bytes = base64.decode(imageString);
      setState(() {
        _imageBytes = bytes;
      });
    } catch (error) {
      print('Error fetching image from server: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Closet - 니트'),
      ),
      body: Center(
        child: _imageBytes.isNotEmpty
            ? Image.memory(
          _imageBytes,
          fit: BoxFit.cover,
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}
