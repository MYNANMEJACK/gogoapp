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
        title: Text(product['name']),
      ),
      body: Padding(
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
              product['description'] ?? '无描述信息。',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            ElevatedButton.icon(
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
              icon: Icon(Icons.shopping_cart),
              label: Text('加入購物車'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}