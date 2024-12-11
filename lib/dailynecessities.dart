import 'package:flutter/material.dart';

class DailyNecessitiesPage extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('生活用品'),
      ),
      backgroundColor: Colors.white, 
      body: Center(
        child: Text(
          '生活用品',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
