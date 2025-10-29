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
        // 纯白背景,简约干净
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB), // 浅灰边框
          width: 2, // 加粗边框：1 → 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 轻量化工具栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF6B7280), // 中灰色
                ),
                const SizedBox(width: 8),
                const Text(
                  '输入文本',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151), // 深灰色
                  ),
                ),
                const Spacer(),
                // 粘贴按钮
                IconButton(
                  icon: const Icon(Icons.content_paste_outlined, size: 18),
                  onPressed: _pasteFromClipboard,
                  tooltip: '粘贴',
                  color: const Color(0xFF3B82F6), // Tailwind Blue
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
                // 清除按钮
                if (widget.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: widget.onClear,
                    tooltip: '清除',
                    color: const Color(0xFF9CA3AF), // 浅灰色
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFF3F4F6), // 极浅灰分割线
          ),
          // 文本输入框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入要翻译的文本...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFD1D5DB), // 占位符浅灰
                  fontSize: 15,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF111827), // 深色文本
              ),
              onChanged: widget.onTextChanged,
            ),
          ),
          // 字数统计
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '字数: ${widget.wordCount}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF), // 次要文本灰色
              ),
            ),
          ),
        ],
      ),
    );
  }
}
