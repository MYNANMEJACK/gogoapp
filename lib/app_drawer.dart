import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'UserOrders.dart'; // 引入 UserOrdersPage 的文件

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 112, 82, 82),
            ),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.isLoggedIn ? 'Hello, ${userProvider.userName}' : '请登录',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 131, 131),
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('登出'),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('我的賬戶'),
            onTap: () {
              Navigator.pop(context); // 當前僅關閉 Drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('我的訂單'),
            onTap: () {
              Navigator.pop(context); // 關閉 Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserOrdersPage()), // 跳轉到 UserOrdersPage
              );
            },
          ),
        ],
      ),
    );
  }
}