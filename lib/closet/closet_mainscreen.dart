import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Categories.dart';
import 'main_catgory_buttons.dart';
import 'add_clothes/pic_toServer_screen.dart';

class ClosetHomePage extends StatefulWidget {
  @override
  _ClosetHomePageState createState() => _ClosetHomePageState();
}

class _ClosetHomePageState extends State<ClosetHomePage> {
  final List<String> categories = Categories.categories;
  final Map<String, List<String>> subCategories = Categories.subCategories;

  String? _selectedCategory;
  String? _selectedSubCategory;

  List<Map<String, String>> items = [
    {'image': 'path/to/your/image1.jpg', 'label': 'Item 1'},
    // Add more items here
  ];

  int _pageNumber = 1;
  void _onItemTapped(int index) {
    setState(() {
      _pageNumber = index;
    });
  }

  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('내 옷장'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySubCategoryWidgets(
              categories: categories,
              subCategories: subCategories,
              onCategorySelected: _saveSelectedCategory,
              onSubCategorySelected: (subCategory) {
                setState(() {
                  _selectedSubCategory = subCategory;
                });
              },
              selectedCategory: _selectedCategory,
              selectedSubCategory: _selectedSubCategory,
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
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
            ),
          ],
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
          currentIndex: _pageNumber,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // 선택한 카테고리를 저장하는 메소드
  void _saveSelectedCategory(String category) {
    setState(() {
      _selectedCategory = category;
      // 선택한 상위 카테고리에 해당하는 하위 카테고리 초기화
      _selectedSubCategory = null;

      // 자동으로 첫 번째 하위 카테고리 선택
      if (subCategories.containsKey(category) &&
          subCategories[category]!.isNotEmpty) {
        _selectedSubCategory = subCategories[category]![0];
        // 선택한 첫 번째 하위 카테고리를 부모 위젯으로 전달
        setState(() {
          _selectedSubCategory = subCategories[category]![0];
        });
      }
    });
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      final msg = "앱을 종료하려면 한 번 더 누르세요";

      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    }

    return Future.value(true);
  }
}
