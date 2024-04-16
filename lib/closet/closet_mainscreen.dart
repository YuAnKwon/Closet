import 'package:flutter/material.dart';
import 'add_clothes/pic_toServer_screen.dart';

class ClosetHomePage extends StatefulWidget {
  @override
  _ClosetHomePageState createState() => _ClosetHomePageState();
}

class _ClosetHomePageState extends State<ClosetHomePage> {

  // Dummy data for your grid items
  List<Map<String, String>> items = [
    {'image': 'path/to/your/image1.jpg', 'label': 'Item 1'},
    // Add more items here
  ];

  int _pagenumber = 1;
  void _onItemTapped(int index) {
    setState(() {
      _pagenumber = index;
    });
    // Handle item tap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 옷장'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return GridTile(
            child: Text('사진'), //Image.asset(items[index]['image'])
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraCapture()),
          );
        },
        tooltip: '옷 추가',
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Look Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '옷장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '코디 추천',
          ),
        ],
        currentIndex: _pagenumber,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),

    );
  }
}
