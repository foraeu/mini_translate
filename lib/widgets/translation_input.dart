import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 翻译输入组件
/// 提供多行文本输入、清除和粘贴功能
class TranslationInput extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;
  final VoidCallback onClear;
  final int wordCount;

  const TranslationInput({
    super.key,
    required this.text,
    required this.onTextChanged,
    required this.onClear,
    required this.wordCount,
  });

  @override
  State<TranslationInput> createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(TranslationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      _controller.text = clipboardData.text!;
      widget.onTextChanged(clipboardData.text!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已粘贴'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 使用纯白色背景
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 工具栏
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
            child: Row(
              children: [
                Text(
                  '输入文本',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // 粘贴按钮
                IconButton(
                  icon: const Icon(Icons.content_paste, size: 19),
                  onPressed: _pasteFromClipboard,
                  tooltip: '粘贴',
                  color: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                // 清除按钮
                if (widget.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 19),
                    onPressed: widget.onClear,
                    tooltip: '清除',
                    color: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 文本输入框
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请输入要翻译的文本...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              style: const TextStyle(fontSize: 15, height: 1.4),
              onChanged: widget.onTextChanged,
            ),
          ),
          // 字数统计
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              '字数: ${widget.wordCount}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
