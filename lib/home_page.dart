import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'drinks.dart';
import 'dailynecessities.dart';
import 'fruitsandvegetables.dart';
import 'ProductsPage.dart';
import 'image_carousel.dart';
import 'recommended_products.dart'; 
import 'discount.dart'; 
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imgList = [];
  List<Map<String, String>> logoList = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchImages();
    populateLogoList();
  }

  void populateLogoList() {
    logoList = [
      {'path': 'assets/images/logo1.png', 'name': '飲品'},
      {'path': 'assets/images/logo2.png', 'name': '糧油'},
      {'path': 'assets/images/logo3.png', 'name': '果蔬'},
      {'path': 'assets/images/logo4.png', 'name': '生活用品'},
    ];
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/images'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          imgList = data.map((item) => item as String).toList();
        });
      } else {
        throw Exception('Failed to load images with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void navigateToProductPage(String productName) {
    Widget page;
    switch (productName) {
      case '飲品':
        page = DishSelectorPage();
        break;
      case '糧油':
        page = ProductsPage();
        break;
      case '果蔬':
        page = FruitsAndVegetablesPage();
        break;
      case '生活用品':
        page = DailyNecessitiesPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: ListView(
      children: <Widget>[
        if (imgList.isNotEmpty)
          ImageCarousel(imgList: imgList),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: logoList.map((logo) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () => navigateToProductPage(logo['name']!),
                  child: Container(
                    width: 90,
                    height: 90,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(logo['path']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(logo['name']!, style: TextStyle(fontSize: 12)),
              ],
            )).toList(),
          ),
        ),
        SizedBox(height: 15),
        RecommendedProducts(),
        SizedBox(height: 15),
        discount(),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(errorMessage, style: TextStyle(color: Colors.red)),
          ),
      ],
    ),
  );
}
}