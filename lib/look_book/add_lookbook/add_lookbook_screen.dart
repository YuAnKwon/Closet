import 'package:flutter/material.dart';
import 'select_image.dart';

class AddLookBook extends StatefulWidget {
  final String? image;
  final int? num;

  const AddLookBook({Key? key, this.image, this.num}) : super(key: key);

  @override
  State<AddLookBook> createState() => _AddLookBookState();
}

class _AddLookBookState extends State<AddLookBook> {

  final List<String> items = ['상의', '하의', '신발'];


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('look 선택'),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...items.map((name) {
                return ClothingBox(
                    name: name,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectImage(category: name),
                        ),
                      );
                    },
                  );

              }).toList(),
              ClothingBox(
                label: '가방 선택',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectImage(category: '가방'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClothingBox extends StatelessWidget {
  final String? name;
  final String? label;
  final VoidCallback onTap;

  const ClothingBox({
    Key? key,
    this.name,
    this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        color: Colors.grey[300],
        child: Center(
          child: Text(
            name != null ? '$name 선택' : label!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
