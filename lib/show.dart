import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;

import 'api_config.dart';

class Chat extends StatefulWidget {
  String dep;
  String level;

  Chat({required this.level, required this.dep});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController message = TextEditingController();
  List<dynamic> _messages = [];
  String? formattedDate;
  final DateTime _currentDate = DateTime.now();

  Future<void> _sendMessage(String mess) async {
    if (mess.trim().isEmpty) return;

    try {
      final res = await http.post(
        ApiConfig.endpoint('message.php'),
        body: {
          'level': widget.level,
          'message': mess,
          'dep': widget.dep,
          'time': formattedDate.toString(),
        },
      );

      if (res.statusCode == 200) {
        message.clear();
        await fetchNotifications();
      }
    } catch (_) {
      // Preserve the current screen if the API is temporarily unavailable.
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.post(
        ApiConfig.endpoint('showmessage.php'),
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
        _messages = decoded;
      });
    } catch (_) {
      // Preserve the existing messages if refreshing fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy MMMM d');
    formattedDate = dateFormat.format(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index] as Map<String, dynamic>;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BubbleSpecialOne(
                      text: item['mess']?.toString() ?? '',
                      isSender: false,
                      color: Colors.green,
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: message,
                    decoration: InputDecoration(labelText: 'Message'),
                    keyboardType: TextInputType.text,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(message.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
