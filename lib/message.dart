import 'package:flutter/material.dart';

import 'api_client.dart';
import 'register.dart';
import 'showmessageadmin.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.department});

  final String department;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _messageController = TextEditingController();

  String _selectedLevel = 'L1';
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showMessage('اكتب الرسالة أولًا');
      return;
    }

    setState(() => _isSending = true);

    try {
      final response = await ApiClient.post(
        'message.php',
        auth: ApiAuth.admin,
        body: {
          'level': _selectedLevel,
          'message': message,
          'dep': widget.department,
        },
      );

      final payload = ApiClient.decodeObject(response.body);
      final success = payload['success'] == true;

      if (!mounted) return;

      if ((response.statusCode == 200 || response.statusCode == 201) && success) {
        _messageController.clear();
        _showMessage('تم إرسال الرسالة بنجاح');
      } else {
        _showMessage('تعذر إرسال الرسالة');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('تعذر الاتصال بالخادم');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String get _departmentTitle {
    return switch (widget.department) {
      'IT' => 'قسم تقنية المعلومات',
      'acc' => 'المحاسبة',
      'mang' => 'إدارة الأعمال',
      'info' => 'نظم المعلومات',
      'english' => 'اللغة الإنجليزية',
      'quran' => 'القرآن وعلومه',
      'shar' => 'الشريعة',
      'feg' => 'الفقه',
      _ => widget.department,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_departmentTitle),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                ApiClient.clearAdminToken();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
            ),
            IconButton(
              tooltip: 'إضافة طالب',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterPage(department: widget.department),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'المستوى',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['L1', 'L2', 'L3', 'L4', 'all']
                      .map(
                        (level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(level == 'all' ? 'جميع المستويات' : level),
                        ),
                      )
                      .toList(),
                  onChanged: _isSending
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedLevel = value);
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                    labelText: 'الرسالة',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: const Icon(Icons.send_outlined),
                  label: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إرسال الرسالة'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminMessagesPage(
                          department: widget.department,
                          level: _selectedLevel,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('عرض الرسائل المرسلة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
