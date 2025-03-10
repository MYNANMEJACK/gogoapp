import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gogoapp/UserOrders.dart'; 
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items; 
  final double totalPrice; 

  const CheckoutPage({
    Key? key,
    required this.items,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedDeliveryMethod = '地址配送'; 
  String? _selectedPickupLocation; 
  String _selectedPaymentMethod = 'FPS'; 

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController(); 
  final TextEditingController _expiryDateController = TextEditingController(); 
  final TextEditingController _cvvController = TextEditingController(); 
  final TextEditingController _cardHolderNameController = TextEditingController(); 

  List<String> _pickupLocations = []; 
  bool _isLoadingPickupLocations = false; 
  bool _isSubmitting = false; 

  String? _userId; // 仅保留 userId

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); 
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        setState(() {
          _userId = userId;
        });
      } else {
        throw Exception('用戶未登錄或登錄信息丟失');
      }
    } catch (error) {
      _showError('加載用戶信息失敗，請重新登錄');
      Navigator.pop(context); 
    }
  }

  Future<void> _loadPickupLocations() async {
    if (_isLoadingPickupLocations) return; 

    setState(() {
      _isLoadingPickupLocations = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://20.249.177.153:8080/pickup-locations'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            _pickupLocations = List<String>.from(
              data.map((location) => location['address']),
            );
          });
        } else if (data is Map) {
          setState(() {
            _pickupLocations = [data['address']];
          });
        } else {
          _showError('無效的自取地點數據格式');
        }
      } else {
        _showError('加載自取地點失敗，請稍後重試');
      }
    } catch (error) {
      print('加載自取地點失敗：$error');
      _showError('加載自取地點失敗，請檢查您的網絡連接');
    } finally {
      setState(() {
        _isLoadingPickupLocations = false;
      });
    }
  }

  // 提交訂單
  Future<void> submitOrder() async {
    if (_userId == null) {
      _showError('用戶信息加載失敗，無法提交訂單');
      return;
    }

    if (_selectedDeliveryMethod == '地址配送' && _addressController.text.isEmpty) {
      _showError('請輸入配送地址');
      return;
    }

    if (_selectedDeliveryMethod == '自取' && _selectedPickupLocation == null) {
      _showError('請選擇自取地址');
      return;
    }

    if (_selectedPaymentMethod == '信用卡') {
      if (_cardNumberController.text.isEmpty ||
          _expiryDateController.text.isEmpty ||
          _cvvController.text.isEmpty ||
          _cardHolderNameController.text.isEmpty) {
        _showError('請填寫完整的信用卡信息');
        return;
      }
    }

    if (_isSubmitting) return; 

    setState(() {
      _isSubmitting = true;
    });

    try {

      final orderData = {
        'userId': _userId, 
        'deliveryMethod': _selectedDeliveryMethod, 
        'paymentMethod': _selectedPaymentMethod, 
        'address': _addressController.text.isNotEmpty ? _addressController.text : null, 
        'pickupLocation': _selectedPickupLocation, 
        'creditCardInfo': _selectedPaymentMethod == '信用卡'
            ? {
                'cardNumber': _cardNumberController.text,
                'expiryDate': _expiryDateController.text,
                'cvv': _cvvController.text,
                'cardHolderName': _cardHolderNameController.text,
              }
            : null,
        'items': widget.items.map((item) {
          return {
            'name': item['name'], 
            'quantity': item['quantity'], 
            'price': item['price'], 
          };
        }).toList(),
        'totalPrice': widget.totalPrice, 
      };

      print('提交的訂單信息: ${jsonEncode(orderData)}');

      final response = await http.post(
        Uri.parse('http://20.249.177.153:8080/api/orders'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData), 
      );

      if (response.statusCode == 201) {
      
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('訂單提交成功！訂單編號：${responseBody['orderId']}')),
        );

    
        final cart = context.read<CartProvider>();
        cart.clearCart();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserOrdersPage()),
        );
      } else {
  
        final errorResponse = json.decode(response.body);
        _showError('提交失敗：${errorResponse['message']}');
      }
    } catch (error) {
      print('提交訂單失敗：$error');
      _showError('提交訂單失敗，請檢查網絡或稍後重試');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _getPaymentQRCode(String paymentMethod) {
    switch (paymentMethod) {
      case 'FPS':
        return Image.network('https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/IMG_9194.jpeg?alt=media&token=7f232285-7643-455a-91e0-1dbb4a1e8ea6', width: 150);
      case '支付寶':
        return Image.network('https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/IMG_9194.jpeg?alt=media&token=7f232285-7643-455a-91e0-1dbb4a1e8ea6', width: 150);
      case '微信支付':
        return Image.network('https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/IMG_9194.jpeg?alt=media&token=7f232285-7643-455a-91e0-1dbb4a1e8ea6', width: 150);
      default:
        return const Text('此支付方式無需二維碼');
    }
  }

  @override
Widget build(BuildContext context) {
  if (_userId == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        '結算中心',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 255, 80, 80),
      elevation: 0,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '訂單摘要:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // 明確設置高度
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    leading: Image.network(
                      item['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Text('數量: ${item['quantity']}'),
                    trailing: Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '總計: \$${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '配送方式:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedDeliveryMethod,
              isExpanded: true,
              items: ['地址配送', '自取'].map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDeliveryMethod = newValue!;
                  _addressController.clear();
                  if (newValue == '自取') {
                    _loadPickupLocations();
                  }
                });
              },
            ),
            if (_selectedDeliveryMethod == '地址配送') ...[
              const SizedBox(height: 16),
              const Text(
                '配送地址:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: '請輸入您的配送地址',
                ),
              ),
            ],
            if (_selectedDeliveryMethod == '自取') ...[
              const SizedBox(height: 16),
              _isLoadingPickupLocations
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedPickupLocation,
                      isExpanded: true,
                      hint: const Text('選擇自取地點'),
                      items: _pickupLocations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPickupLocation = newValue;
                        });
                      },
                    ),
            ],
            const SizedBox(height: 16),
            const Text(
              '支付方式:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              isExpanded: true,
              items: ['FPS', '支付寶', '微信支付', '信用卡'].map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == '信用卡') ...[
              const Text(
                '信用卡信息:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  hintText: '卡號',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  hintText: '有效期 (MM/YY)',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  hintText: 'CVV',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cardHolderNameController,
                decoration: const InputDecoration(
                  hintText: '持卡人姓名',
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_selectedPaymentMethod != '信用卡')
              _getPaymentQRCode(_selectedPaymentMethod),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : submitOrder,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 255, 80, 80),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          '提交訂單',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}