import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cart_page.dart';
import 'product_details_page.dart';

class FruitsAndVegetablesPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<FruitsAndVegetablesPage> {
  List<dynamic> products = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/products/type/food'));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = '加载产品失败';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void addToCart(Map<String, dynamic> product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem({...product, 'quantity': 1});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} 已經添加到購物車')),
    );
  }

  void viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  void viewProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () => viewProductDetails(product),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                              child: Image.network(
                                product['image_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.broken_image, size: 50));
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${product['price']}',
                                style: TextStyle(fontSize: 12, color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () => addToCart(product),
                                child: Text('ADD TO car'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 36),
                                  backgroundColor: const Color.fromARGB(255, 255, 153, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

