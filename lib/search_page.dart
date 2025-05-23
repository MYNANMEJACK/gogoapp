import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_details_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _products = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://20.249.177.153:8080/products/search?search=$query'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['products'];
        setState(() {
          _products = data.map((product) => Product.fromJson(product)).toList();
        });
      } else {
        print('無法獲取搜索結果: ${response.statusCode}');
      }
    } catch (error) {
      print('獲取搜索結果時出錯: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索產品',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (query) => _searchProducts(query),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 80, 80),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text('沒有找到匹配的產品'))
              : _buildProductList(),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 50);
              },
            ),
            title: Text(product.name),
            subtitle: Text('價格: \$${product.price.toStringAsFixed(2)}'),
            onTap: () {
              // 关闭键盘
              FocusScope.of(context).unfocus();

              // 跳转到产品详情页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    product: {
                      'id': product.id,
                      'name': product.name,
                      'image_url': product.imageUrl,
                      'price': product.price,
                      'description': product.description,
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Product {
  final int id;
  final String imageUrl;
  final String name;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      imageUrl: json['image_url'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'] ?? '無描述信息。',
    );
  }
}
