import 'package:flutter/material.dart';

import 'api_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.department});

  final String department;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _codeController = TextEditingController();
  final _fullnameController = TextEditingController();

  String _selectedLevel = 'L1';
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  Future<void> _registerStudent() async {
    final code = _codeController.text.trim();
    final fullname = _fullnameController.text.trim();

    if (code.isEmpty || fullname.isEmpty) {
      _showMessage('أدخل رقم القيد والاسم الكامل');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await ApiClient.post(
        'register.php',
        auth: ApiAuth.admin,
        body: {
          'code': code,
          'fullname': fullname,
          'dep': widget.department,
          'level': _selectedLevel,
        },
      );

      final payload = ApiClient.decodeObject(response.body);
      final success = payload['success'] == true;

      if (!mounted) return;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          success) {
        _codeController.clear();
        _fullnameController.clear();
        _showMessage('تم إضافة الطالب بنجاح');
      } else if (response.statusCode == 409) {
        _showMessage('رقم القيد موجود مسبقًا');
      } else {
        _showMessage('تعذر إضافة الطالب');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('تعذر الاتصال بالخادم');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة طالب'),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'رقم القيد',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fullnameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'المستوى',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['L1', 'L2', 'L3', 'L4']
                      .map(
                        (level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(level),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedLevel = value);
                          }
                        },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _registerStudent,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تسجيل الطالب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
