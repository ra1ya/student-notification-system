import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'adminlogin.dart';
import 'api_config.dart';
import 'showmessage.dart';

class Studentlogin extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Studentlogin> {
  final code = TextEditingController();
  String? errorText;
  String _errorMessage = '';

  Future<void> _loginUser() async {
    try {
      final response = await http.post(
        ApiConfig.endpoint('studentlogin.php'),
        body: {'code': code.text},
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'تعذر الاتصال بالخادم';
        });
        return;
      }

      final userData = jsonDecode(response.body) as Map<String, dynamic>;

      if (userData['result'] == 'not here') {
        setState(() {
          errorText = 'رقم القيد غير موجود';
        });
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            dep: userData['dep'].toString(),
            level: userData['level'].toString(),
          ),
        ),
      );
    } catch (_) {
      setState(() {
        _errorMessage = 'تعذر الاتصال بالخادم';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            title: Text('تسجيل دخول كطالب'),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'admin') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'admin',
                    child: Text('حساب مسؤول'),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: code,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'رقم القيد',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              Visibility(
                visible: errorText != null,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    errorText ?? '',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
