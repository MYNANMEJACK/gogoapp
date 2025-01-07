import 'package:flutter/material.dart';
import 'package:gogoapp/user_profile.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'UserOrders.dart'; // 引入 UserOrdersPage 的文件
import 'login.dart'; // 引入 login.dart 文件

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromARGB(255, 255, 80, 80), // 设置整个 Drawer 背景为深红色
        child: Column(
          children: [
            // Drawer 头部
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 80, 80), // 和整体背景一致
              ), // 确保没有多余的背景或边框
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white, // 头像背景为白色
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color.fromARGB(255, 132, 1, 1), // 图标颜色为深红色
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userProvider.isLoggedIn ? 'Hello, ${userProvider.userName}' : '请登录',
                      style: TextStyle(
                        color: Colors.white, // 文字颜色为白色
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // 粗体
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Drawer 功能列表
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle, color: Colors.white, size: 24),
                    title: Text(
                      '我的賬戶',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // 粗体
                        color: Colors.white, // 白色文字
                      ),
                    ),
                    onTap: () {
  Navigator.pop(context); // 关闭 Drawer
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfilePage(), // 跳转到用户资料页面
    ),
  );
},
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                    title: Text(
                      '我的訂單',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // 粗体
                        color: Colors.white, // 白色文字
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // 关闭 Drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserOrdersPage()), // 跳转到 UserOrdersPage
                      );
                    },
                  ),
                ],
              ),
            ),
            // 保留登出按钮
            Divider(color: Colors.white), // 仅保留登出按钮上方的分割线
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.white, size: 24),
                title: Text(
                  '登出',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // 粗体
                    color: Colors.white, // 白色文字
                  ),
                ),
                onTap: () {
                  Provider.of<UserProvider>(context, listen: false).logout();
                  Navigator.pop(context); // 关闭 Drawer
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // 跳转到 LoginPage
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
