import 'package:flutter/material.dart';

import 'adminlogin.dart';
import 'api_client.dart';
import 'showmessage.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _errorText = 'أدخل رقم القيد');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final response = await ApiClient.post(
        'studentlogin.php',
        body: {'code': code},
      );

      final payload = ApiClient.decodeObject(response.body);
      final success = payload['success'] == true;
      final token = payload['token']?.toString() ?? '';
      final student = payload['student'];

      if (response.statusCode != 200 ||
          !success ||
          token.isEmpty ||
          student is! Map) {
        if (!mounted) return;
        setState(() => _errorText = 'رقم القيد غير موجود');
        return;
      }

      final department = student['dep']?.toString() ?? '';
      final level = student['level']?.toString() ?? '';

      if (department.isEmpty || level.isEmpty) {
        if (!mounted) return;
        setState(() => _errorText = 'بيانات الطالب غير مكتملة');
        return;
      }

      ApiClient.setStudentToken(token);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentMessagesPage(
            department: department,
            level: level,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'تعذر الاتصال بالخادم');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل دخول الطالب'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'دخول المسؤول',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _loginUser();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'رقم القيد',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorText != null)
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _loginUser,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('تسجيل الدخول'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
