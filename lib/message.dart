import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;

import 'api_config.dart';
import 'register.dart';
import 'showmessageadmin.dart';

class Message extends StatefulWidget {
  String dep;

  Message({required this.dep});

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Message> {
  String _selectedValue = 'L1';
  String? formattedDate;
  final DateTime _currentDate = DateTime.now();
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _submitData() async {
    try {
      final response = await http.post(
        ApiConfig.endpoint('message.php'),
        body: {
          'level': _selectedValue,
          'message': _textFieldController.text,
          'dep': widget.dep,
          'time': formattedDate.toString(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الرسالة بنجاح')),
        );
        _textFieldController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إرسال الرسالة')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الاتصال بالخادم')),
      );
    }
  }

  void submit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShowAdmin(dep: widget.dep, level: _selectedValue),
      ),
    );
  }

  String _departmentTitle() {
    switch (widget.dep) {
      case 'IT':
        return 'قسم تقنية المعلومات';
      case 'acc':
        return 'محاسبة';
      case 'mang':
        return 'إدارة أعمال';
      case 'info':
        return 'نظم معلومات';
      case 'english':
        return 'اللغة الإنجليزية';
      case 'quran':
        return 'القرآن وعلومه';
      case 'shar':
        return 'الشريعة';
      case 'feg':
        return 'الفقه';
      default:
        return widget.dep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy MMMM d');
    formattedDate = dateFormat.format(_currentDate);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_departmentTitle()),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'reg') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(dep: widget.dep),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'reg',
                  child: Text('إضافة طالب'),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  alignment: Alignment.centerRight,
                  value: _selectedValue,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedValue = newValue!;
                    });
                  },
                  items: ['L1', 'L2', 'L3', 'L4', 'all']
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, textAlign: TextAlign.right),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'المستوى',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  maxLines: 10,
                  minLines: 3,
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    labelText: 'الرسالة',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                  ),
                  child: Text(
                    'إرسال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                  ),
                  child: Text(
                    'عرض الرسائل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
