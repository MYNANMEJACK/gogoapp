import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // 確保引入 HomePage 文件

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({Key? key}) : super(key: key);

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  String? _userId; // 存儲用戶ID
  List<Map<String, dynamic>> _orders = []; // 訂單數據
  bool _isLoading = true; // 加載狀態
  String? _errorMessage; // 錯誤信息

  @override
  void initState() {
    super.initState();
    _loadUserInfoAndFetchOrders(); // 初始化加載用戶信息並獲取訂單
  }

  // 加載用戶ID並獲取訂單
  Future<void> _loadUserInfoAndFetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 調試打印 SharedPreferences 中的鍵和值
      print('SharedPreferences 中的鍵: ${prefs.getKeys()}');
      print('SharedPreferences 中的 userId: ${prefs.getString('userId')}');

      // 獲取 userId
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('用戶未登錄');
      }

      setState(() {
        _userId = userId;
      });

      // 獲取訂單數據
      await _fetchOrders(userId);
    } catch (error) {
      setState(() {
        _errorMessage = '加載訂單失敗：${error.toString()}';
        _isLoading = false;
      });
    }
  }

  // 獲取訂單數據
  Future<void> _fetchOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://20.249.177.153:8080/api/orders/user?userId=$userId'),
      );

      print('訂單接口響應碼: ${response.statusCode}');
      print('訂單接口返回數據: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['orders'] != null && data['orders'] is List) {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(data['orders']);
            _isLoading = false;
          });
        } else {
          throw Exception('無效的訂單數據格式');
        }
      } else {
        setState(() {
          _errorMessage = '獲取訂單失敗，請稍後重試';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = '加載訂單失敗：${error.toString()}';
        _isLoading = false;
      });
    }
  }

 
  void _navigateToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage();
        return false; // 阻止返回操作
      },
      child: Scaffold(
        appBar: AppBar(

           backgroundColor: const Color.fromARGB(255, 255, 80, 80),
          title: const Text('我的訂單',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
        ),
         centerTitle: true, 
           ),
        body: Column(
          children: [
            _buildUserInfoWidget(), // 顯示用戶信息
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator()) // 加載中
                  : _errorMessage != null
                      ? _buildErrorWidget() // 顯示錯誤
                      : _buildOrdersList(), // 顯示訂單列表
            ),
          ],
        ),
      ),
    );
  }

  // 用戶信息小部件
  Widget _buildUserInfoWidget() {
    if (_userId == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '用戶ID: $_userId',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  // 錯誤信息小部件
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage ?? '未知錯誤',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserInfoAndFetchOrders,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  // 訂單列表小部件
  Widget _buildOrdersList() {
    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          '暫無訂單',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '訂單編號: ${order['orderId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      order['status'] ?? '未知狀態',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order['status'] ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('總價: \$${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                const SizedBox(height: 8),
                Text('配送方式: ${order['deliveryMethod'] ?? '未提供'}'),
                const SizedBox(height: 8),
                Text('支付方式: ${order['paymentMethod'] ?? '未提供'}'),
                const SizedBox(height: 8),
                Text('訂單時間: ${order['createdAt'] ?? '未知'}'),
                const SizedBox(height: 8),
                if (order['items'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '商品列表:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from(order['items'].map((item) {
                        return Text(
                          '- ${item['productName']} x${item['quantity']} (\$${item['price']})',
                        );
                      })),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 訂單狀態顏色
  Color _getStatusColor(String status) {
    switch (status) {
      case '待確認':
        return Colors.orange;
      case '配送中':
        return Colors.blue;
      case '已完成':
        return Colors.green;
      case '到達自取點':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}