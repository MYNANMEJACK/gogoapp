import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // 主頁面
import 'user_provider.dart'; // 用戶狀態管理
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 本地存儲
import 'RegisterPage.dart'; // 註冊頁面

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 保存用戶信息到本地存儲
  Future<void> _saveUserInfo(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId); // 保存用戶ID

    // 打印存儲的值，便於調試
    print('存儲的 userId: $userId');
  }

  // 登錄方法
  Future<void> _login() async {
    // 檢查用戶名和密碼是否為空
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showDialog('輸入錯誤', '用戶名和密碼不能為空。');
      print('用戶名或密碼為空，無法登錄。');
      return;
    }

    setState(() {
      _isLoading = true; // 開始加載
    });

    var url = Uri.parse('http://10.0.2.2:3000/login'); // 修改為你的 API 地址
    print('正在向 $url 發送登錄請求...');

    try {
      // 發起 POST 請求
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      print('服務器返回的狀態碼: ${response.statusCode}');
      print('服務器返回的完整響應: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // 檢查返回的 JSON 是否包含 userId
        final userId = responseBody['userId']?.toString() ?? '';

        if (userId.isEmpty) {
          print('登錄成功但返回的 userId 為空！');
          _showDialog('登錄失敗', '服務器返回無效的登錄信息。');
          return;
        }

        // 打印解析的 userId
        print('解析到的 userId: $userId');

        // 保存用戶信息到本地存儲
        await _saveUserInfo(userId);

        // 使用 Provider 更新用戶狀態
        Provider.of<UserProvider>(context, listen: false)
            .setUser(_usernameController.text);

        print('用戶狀態已更新，跳轉到主頁面。');

        // 跳轉到主頁面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // 服務器返回了錯誤
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? '登錄失敗，原因未知';
        print('登錄失敗，服務器返回的錯誤信息: $message');
        _showDialog('登錄失敗', message);
      }
    } catch (e) {
      // 網絡或其他異常
      print('登錄異常: $e');
      _showDialog('網絡異常', '無法連接到服務器：$e');
    } finally {
      setState(() {
        _isLoading = false; // 完成加載
      });
    }
  }

  // 顯示提示對話框
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 關閉對話框
            },
            child: Text('確定'),
          ),
        ],
      ),
    );
  }

  // 構建登錄表單
  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dogcart.png', // 確保圖片路徑正確
              height: 300,
            ),
            const SizedBox(height: 20),
            // 用戶名輸入框
            Container(
              width: 400, // 設置輸入框寬度
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用戶名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 密碼輸入框
            Container(
              width: 400, // 設置輸入框寬度
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密碼',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                obscureText: true, // 隱藏文本
              ),
            ),
            const SizedBox(height: 30),
            // 登錄按鈕
            ElevatedButton(
  onPressed: _isLoading ? null : _login, // 加載中禁用按鈕
  style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(horizontal:180,vertical: 15), // 調整按鈕的內邊距，使其更長
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // 保持圓角樣式
      ),
    ),
    backgroundColor: MaterialStateProperty.all<Color>(
      const Color.fromARGB(255, 255, 80, 80), // 設置背景顏色
    ),
  ),
  child: _isLoading
      ? const CircularProgressIndicator(color: Colors.white) // 加載中顯示白色進度條
      : const Text(
          '登入', // 修改按鈕文字為 Login
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold, // 設置文字為粗體
            color: Colors.white, // 設置文字顏色為白色
          ),
        ),
),
const SizedBox(height: 20),
            // 跳轉到註冊頁面的按鈕
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text(
                '還沒有帳號？註冊',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text(
        'Login', 
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
      body: Stack(
        children: [
          _buildLoginForm(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}