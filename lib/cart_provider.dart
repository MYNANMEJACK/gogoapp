import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // 購物車商品列表
  List<Map<String, dynamic>> _items = [];

  // 獲取購物車內的商品列表
  List<Map<String, dynamic>> get items => _items;

  // 獲取購物車總價
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
  }

  // 添加商品到購物車
  void addItem(Map<String, dynamic> item) {
    int index = _items.indexWhere((existingItem) => existingItem['name'] == item['name']);
    if (index != -1) {
      // 如果商品已經存在，增加數量
      _items[index]['quantity'] += item['quantity'];
    } else {
      // 如果商品不存在，添加到購物車
      _items.add(item);
    }
    notifyListeners(); // 通知監聽者更新
  }

  // 從購物車中移除商品
  void removeItem(Map<String, dynamic> item) {
    _items.remove(item); // 移除商品
    notifyListeners(); // 通知監聽者更新
  }

  // 更新商品數量
  void updateQuantity(Map<String, dynamic> item, int quantity) {
    if (quantity <= 0) {
      // 如果數量小於等於 0，移除商品
      removeItem(item);
    } else {
      final index = _items.indexWhere((existingItem) => existingItem['name'] == item['name']);
      if (index != -1) {
        // 更新商品數量
        _items[index]['quantity'] = quantity;
        notifyListeners(); // 通知監聽者更新
      }
    }
  }

  // **清空購物車**
  void clearCart() {
    _items.clear(); // 清空購物車列表
    notifyListeners(); // 通知監聽者更新
  }
}