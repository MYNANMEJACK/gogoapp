import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // 導入購物車邏輯
import 'checkout.dart'; // 導入結算頁面

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      title: const Text(
        '購物車', 
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255), 
          fontWeight: FontWeight.bold, 
        ),
      ),
      centerTitle: true, // 讓文字置中
      backgroundColor: const Color.fromARGB(255, 255, 80, 80), 
      elevation: 0, 
      iconTheme: IconThemeData(
        color: Colors.black, 
      ),
    ),
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                '購物車是空的',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Dismissible(
                        key: Key(item['name']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          cart.removeItem(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item['name']} 已經移除購物車')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  item['image_url'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '價格: \$${item['price']}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.red),
                                    onPressed: () => cart.updateQuantity(item, item['quantity'] - 1),
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.green),
                                    onPressed: () => cart.updateQuantity(item, item['quantity'] + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '總計: \$${cart.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (cart.items.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  items: cart.items, // 傳遞購物車商品
                                  totalPrice: cart.totalPrice, // 傳遞總價
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('購物車是空的，無法結算')),
                            );
                          }
                        },
                        child: const Text(
                     '結算', // 按鈕文字
                         style: TextStyle(
                           color: Colors.white, // 設置文字為白色
                                fontWeight: FontWeight.bold, // 可選：設置文字為粗體
                             fontSize: 16, // 可選：設置文字大小
                                      ),
                                         ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 80, 80),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}