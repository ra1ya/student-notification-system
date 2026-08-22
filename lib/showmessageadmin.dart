import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ShowAdmin extends StatefulWidget {
  String dep;
  String level;

  ShowAdmin({required this.dep, required this.level});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ShowAdmin> {
  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.post(
        ApiConfig.endpoint('showadmin.php'),
        body: {
          'dep': widget.dep,
          'level': widget.level,
        },
      );

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return;

      if (!mounted) return;
      setState(() {
        messages = decoded;
      });
    } catch (_) {
      // Keep the existing empty-state behavior when the API is unavailable.
    }
  }

  String _levelTitle() {
    switch (widget.level) {
      case 'L1':
        return 'مستوى أول';
      case 'L2':
        return 'مستوى ثاني';
      case 'L3':
        return 'مستوى ثالث';
      case 'L4':
        return 'مستوى رابع';
      default:
        return 'جميع المستويات';
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
            title: Text(_levelTitle()),
            centerTitle: true,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 30),
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final item = messages[index] as Map<String, dynamic>;
              return ListTile(
                subtitle: Text(
                  item['times']?.toString() ?? '',
                  style: TextStyle(color: Colors.blue),
                ),
                title: Container(
                  width: 250,
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      item['mess']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
