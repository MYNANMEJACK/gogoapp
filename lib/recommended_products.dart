import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'product_details_page.dart';

class RecommendedProducts extends StatefulWidget {
  @override
  _RecommendedProductsState createState() => _RecommendedProductsState();
}

class _RecommendedProductsState extends State<RecommendedProducts> {
  List<dynamic> recommendedProducts = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRecommendedProducts();
  }

  Future<void> fetchRecommendedProducts() async {
    try {
      final response = await http.get(Uri.parse('http://20.249.177.153:8080/products/off'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          recommendedProducts = data;
        });
      } else {
        throw Exception('Failed to load recommended products');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void navigateToProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('猜你喜歡', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 10),
        Card(
          color: const Color.fromARGB(255, 255, 255, 255), // 白色背景
          elevation: 4, // 小阴影
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 215,
            child: recommendedProducts.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedProducts.length,
                    itemBuilder: (context, index) {
                      final product = recommendedProducts[index];
                      return GestureDetector(
                        onTap: () => navigateToProductDetails(product),
                        child: Container(
                          width: 140,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                product['image_url'],
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image, size: 50);
                                },
                              ),
                              SizedBox(height: 5),
                              Text(
                                product['name'],
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Text(
                                '\$${product['price']}',
                                style: TextStyle(fontSize: 12, color: Colors.green),
                              ),
                              SizedBox(height: 5),
                              product['stock'] > 0
                                  ? ElevatedButton(
                                      onPressed: () {
                                        final cart = Provider.of<CartProvider>(context, listen: false);
                                        cart.addItem({
                                          'name': product['name'],
                                          'image_url': product['image_url'],
                                          'price': product['price'],
                                          'quantity': 1,
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${product['name']} 已添加到購物車')),
                                        );
                                      },
                                      child: Text(
                                        '加入購物車',
                                        style: TextStyle(color: Colors.black), // 设置字体颜色为黑色
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 36),
                                        backgroundColor: const Color.fromARGB(255, 255, 191, 191), // 背景颜色
                                        textStyle: TextStyle(fontSize: 12),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: null,
                                      child: Text('賣曬啦'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 36),
                                        textStyle: TextStyle(fontSize: 12),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : errorMessage.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                      )
                    : Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}
