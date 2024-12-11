import 'package:flutter/material.dart';

class FruitsAndVegetablesPage extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('果蔬'),
      ),
      backgroundColor: Colors.white, // 设置背景色为白色
      body: Center(
        child: Text(
          '果蔬',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
