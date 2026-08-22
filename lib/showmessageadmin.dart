import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({
    super.key,
    required this.department,
    required this.level,
  });

  final String department;
  final String level;

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  List<Map<String, dynamic>> _messages = const [];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final response = await ApiClient.post(
        'showadmin.php',
        auth: ApiAuth.admin,
        body: {
          'dep': widget.department,
          'level': widget.level,
        },
      );

      if (response.statusCode != 200) {
        throw StateError('Unable to fetch messages.');
      }

      final messages = ApiClient.decodeMessages(response.body);

      if (!mounted) return;
      setState(() => _messages = messages);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'تعذر تحميل الرسائل');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _levelTitle {
    return switch (widget.level) {
      'L1' => 'المستوى الأول',
      'L2' => 'المستوى الثاني',
      'L3' => 'المستوى الثالث',
      'L4' => 'المستوى الرابع',
      _ => 'جميع المستويات',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_levelTitle),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  String _formatTimestamp(dynamic value) {
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed == null) return raw;
    return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorText!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _fetchMessages,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(child: Text('لا توجد رسائل في هذا المستوى'));
    }

    return RefreshIndicator(
      onRefresh: _fetchMessages,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _messages[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BubbleSpecialOne(
                text: item['mess']?.toString() ?? '',
                isSender: false,
                color: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, top: 2),
                child: Text(
                  _formatTimestamp(item['times']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
