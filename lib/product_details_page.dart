import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['name'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 80, 80), // AppBar背景颜色
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Image.network(
                        product['image_url'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Icon(Icons.broken_image, size: 50));
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      product['name'],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '價格: \$${product['price']}',
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product['description'] ?? '無描述信息。',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.addItem({
                    'name': product['name'],
                    'image_url': product['image_url'],
                    'price': product['price'],
                    'quantity': 1,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product['name']} 已加入購物車')),
                  );
                },
                icon: Icon(Icons.shopping_cart, color: Colors.black), // 图标颜色为黑色
                label: Text(
                  '加入購物車',
                  style: TextStyle(color: Colors.black), // 字体颜色为黑色
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 255, 191, 191), // 按钮背景颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // 圆角按钮
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
