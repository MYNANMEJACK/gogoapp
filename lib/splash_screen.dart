import 'package:flutter/material.dart';
import 'login.dart';  

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds:4 ),  // 動畫時間
      vsync: this,
    );

    animation = CurvedAnimation(parent: controller!, curve: Curves.easeIn);  // 使用 easeIn 曲线

    // 動畫結束的時候go to login 畫面
    animation!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });

    controller!.forward();  // 動畫
  }

  @override
  void dispose() {
    controller!.dispose();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: animation!,
        child: Center(
          child: Image.asset('assets/images/GOGO.png'),  // 圖片引用
        ),
      ),
    );
  }
}