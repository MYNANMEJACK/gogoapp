import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? additionalUserInfo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userName = userProvider.userName;
    final apiUrl = 'http://10.0.2.2:3000/users/$userName';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          additionalUserInfo = data['user'];
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = '用戶未找到，請檢查用戶名是否正確。';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '無法加載用戶詳情: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '請求失敗，請檢查網絡連接';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的帳戶',
          style: TextStyle(
            color: Colors.white, // 白字
            fontWeight: FontWeight.bold, // 粗體
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 80, 80),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Color.fromARGB(255, 255, 80, 80),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            '${userProvider.userName}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 60, 60, 60),
                            ),
                          ),
                        ),
                        Divider(height: 40, color: Colors.grey),
                        Text(
                          '帳戶資訊',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildInfoCard('電子郵件', additionalUserInfo?['email']),
                        SizedBox(height: 10),
                        _buildInfoCard('手機號碼', additionalUserInfo?['phone']),
                        SizedBox(height: 10),
                        _buildInfoCard('職業', additionalUserInfo?['job']),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String label, String? value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 100, 100),
              ),
            ),
            Expanded(
              child: Text(
                value ?? '未提供',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 60, 60, 60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
