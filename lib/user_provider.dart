import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _userName = "游客"; // 默認用戶名
  bool _isLoggedIn = false; // 默認為未登錄

  // Getter：獲取用戶名
  String get userName => _userName;

  // Getter：獲取登錄狀態
  bool get isLoggedIn => _isLoggedIn;

  get userId => null;

  // 初始化用戶數據（應在應用啟動時調用）
  Future<void> initializeUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userName = prefs.getString('userName') ?? "游客";
      notifyListeners(); // 通知監聽器刷新狀態
    } catch (e) {
      print("加载用户信息失败: $e");
    }
  }

  // 設置用戶信息並保存到本地存儲
  Future<void> setUser(String name) async {
    _userName = name;
    _isLoggedIn = true;
    notifyListeners(); // 通知監聽器刷新狀態
    await _saveToPreferences();
  }

  // 用戶登出並重置狀態
  Future<void> logout() async {
    _userName = "游客";
    _isLoggedIn = false;
    notifyListeners(); // 通知監聽器刷新狀態
    await _saveToPreferences();
  }

  // 私有方法：將用戶信息保存到 SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', _isLoggedIn);
      await prefs.setString('userName', _userName);
    } catch (e) {
      print("保存用户信息失败: $e");
    }
  }

  loadUser() {}
}