import 'package:flutter/material.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'drinks.dart';
import 'fruitsandvegetables.dart';
import 'dailynecessities.dart';
import 'splash_screen.dart';
import 'user_provider.dart';
import 'app_drawer.dart';
import 'cart_page.dart';
import 'search_page.dart';  // 引入SearchPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();
  await userProvider.loadUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text('gogoshop'),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()), // 跳转到搜索页面
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color.fromARGB(255, 254, 0, 0),
            unselectedLabelColor: const Color.fromARGB(255, 0, 0, 0),
            labelColor: const Color.fromARGB(255, 255, 187, 0),
            tabs: [
              Tab(text: '主頁'),
              Tab(text: '飲料'),
              Tab(text: '食物'),
              Tab(text: '酒類'),
              Tab(text: '水果'),
              Tab(text: '生活用品'),
              Tab(text: '急凍食品'),
            ],
          ),
        ),
        drawer: AppDrawer(), // 使用新的AppDrawer组件
        body: TabBarView(
          children: [
            HomePage(),
            DishSelectorPage(),
            DailyNecessitiesPage(),
            FruitsAndVegetablesPage(),
            Center(child: Text('酒类')),
            Center(child: Text('水果')),
            Center(child: Text('生活用品')),
            Center(child: Text('急冻')),
          ],
        ),
      ),
    );
  }
}
