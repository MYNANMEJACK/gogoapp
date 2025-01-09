import 'package:flutter/material.dart';
import 'package:gogoapp/ProductsPage.dart';
import 'package:gogoapp/cart_provider.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'drinks.dart';
import 'fruitsandvegetables.dart';
import 'splash_screen.dart';
import 'user_provider.dart';
import 'app_drawer.dart';
import 'cart_page.dart';
import 'search_page.dart';  

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
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'gogoshop', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 80, 80), 
        iconTheme: const IconThemeData(
  color: Colors.white, // Drawer 圖標顏色設置為白色
),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()), 
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
          ],
          bottom: TabBar(
           
            indicatorColor: const Color.fromARGB(255, 254, 0, 0),
            unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255),
            labelColor: const Color.fromARGB(255, 255, 255, 255),
            tabs: [
              Tab(text: '主頁'),
              Tab(text: '隨機菜式'),
              Tab(text: '所有產品'),
        
            ],
          ),
        ),
        drawer: AppDrawer(), 
        body: TabBarView(
          children: [
            HomePage(),
            DishSelectorPage(),
            ProductsPage(),
            FruitsAndVegetablesPage(),
          ],
        ),
      ),
    );
  }
}
