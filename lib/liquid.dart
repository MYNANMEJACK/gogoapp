import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cart_page.dart';
import 'product_details_page.dart';

// 飲品產品頁面----------------------------------------------------------------------------
class liquidPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<liquidPage> {
  List<dynamic> products = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://20.249.177.153:8080/products/type/drink'));
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 80, 80), // 背景颜色
        centerTitle: true, // 标题居中
        title: Text(
          '飲品', // AppBar标题
          style: TextStyle(
            color: Colors.white, // 白色字体
            fontWeight: FontWeight.bold, // 加粗字体
          ),
        ),
      ),
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
                  final bool inStock = product['stock'] > 0; // 检测库存

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
     Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Flexible( // 让按钮不会强行占据过多空间，防止溢出
          child: inStock
              ? ElevatedButton(
                  onPressed: () => addToCart(product),
                  child: Text(
                    '加入購物車',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    backgroundColor: const Color.fromARGB(255, 255, 191, 191),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: null,
                  child: Text('賣曬啦'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    textStyle: TextStyle(fontSize: 12),
                    backgroundColor: Colors.grey,), 
                                      ),
                                    ),
                            ],
                          ),
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
