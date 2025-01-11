import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cart_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'Dish Selector',
        home: DishSelectorPage(),
        routes: {
          '/cart': (context) => CartPage(),
        },
      ),
    );
  }
}

class DishSelectorPage extends StatefulWidget {
  @override
  _DishSelectorPageState createState() => _DishSelectorPageState();
}

class _DishSelectorPageState extends State<DishSelectorPage> {
  List<Dish> vegetableDishes = [];
  List<Dish> meatDishes = [];
  bool isLoading = false;
  String? selection;
  PageController _pageController = PageController();

  Future<void> fetchDishes(String type) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/random-dishes'));//api從API獲取隨機菜品數據

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          if (type == '一菜一肉') {
            vegetableDishes = [Dish.fromJson(data['vegetables'][0] as Map<String, dynamic>)];
            meatDishes = [Dish.fromJson(data['meats'][0] as Map<String, dynamic>)];
          } else if (type == '两菜两肉') {
            vegetableDishes = (data['vegetables'] as List).map((item) => Dish.fromJson(item)).toList();
            meatDishes = (data['meats'] as List).map((item) => Dish.fromJson(item)).toList();
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dishes or empty response');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  void buyAllItems() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (var dish in vegetableDishes) {
      cart.addItem({
        'name': dish.name,
        'price': dish.prices.first,
        'quantity': 1,
        'image_url': dish.images.first,
      });
    }
    for (var dish in meatDishes) {
      cart.addItem({
        'name': dish.name,
        'price': dish.prices.first,
        'quantity': 1,
        'image_url': dish.images.first,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('所有菜品已加入購物車')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(//頁内切換
              controller: _pageController,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(20),
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/vi.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('今天吃乜', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: selection,
                      hint: Text('請選擇'),
                      items: <String>['一菜一肉', '两菜两肉'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selection = newValue;
                          fetchDishes(selection!);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (selection == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('請選擇')),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text('查看菜品'),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    ...vegetableDishes.map((dish) => DishCard(dish: dish)).toList(),
                    ...meatDishes.map((dish) => DishCard(dish: dish)).toList(),
                    ElevatedButton(
                      onPressed: buyAllItems,
                      child: Text('一鍵加購 (${vegetableDishes.length + meatDishes.length})'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class DishCard extends StatelessWidget {
  final Dish dish;

  const DishCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dish.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Recipe: ${dish.recipe}'),
            SizedBox(height: 10),
            Text('Products: ${dish.products.join(', ')}'),
            SizedBox(height: 10),
            Text('Price: \$${dish.prices.first.toStringAsFixed(2)}'),
            SizedBox(height: 10),
            if (dish.images.isNotEmpty)
              Image.network(
                dish.images.first,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
//定義菜品的屬性和構造函數
class Dish {
  final String name;
  final String recipe;
  final List<String> products;
  final List<double> prices;
  final List<String> images;

  Dish({
    required this.name,
    required this.recipe,
    required this.products,
    required this.prices,
    required this.images,
  });

  factory Dish.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("JSON data is null");
    }
    return Dish(
      name: json['name'] ?? 'Unknown',
      recipe: json['recipe'] ?? 'No recipe provided',
      products: List<String>.from(json['products'] ?? []),
      prices: List<double>.from((json['prices'] ?? []).map((price) => price.toDouble())),
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

void main() {
  runApp(MyApp());
}