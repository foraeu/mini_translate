import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 翻译输出组件
/// 显示翻译结果并提供复制功能
class TranslationOutput extends StatefulWidget {
  final String text;
  final bool isLoading;

  const TranslationOutput({
    super.key,
    required this.text,
    this.isLoading = false,
  });

  @override
  State<TranslationOutput> createState() => _TranslationOutputState();
}

class _TranslationOutputState extends State<TranslationOutput> {
  double _opacity = 0.0;
  String _previousText = '';

  @override
  void didUpdateWidget(TranslationOutput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当文本内容变化时触发淡入动画
    if (widget.text != _previousText && widget.text.isNotEmpty) {
      setState(() {
        _opacity = 0.0;
        _previousText = widget.text;
      });
      
      // 延迟触发淡入
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
    }
    
    // 当文本被清空时重置
    if (widget.text.isEmpty && _previousText.isNotEmpty) {
      setState(() {
        _opacity = 0.0;
        _previousText = '';
      });
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    if (widget.text.isEmpty) return;
    
    await Clipboard.setData(ClipboardData(text: widget.text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('已复制到剪贴板'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  '翻译结果',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // 复制按钮 - 始终占位以保持高度一致
                IconButton(
                  icon: const Icon(Icons.copy, size: 19),
                  onPressed: (widget.text.isNotEmpty && !widget.isLoading)
                      ? () => _copyToClipboard(context)
                      : null,
                  tooltip: '复制',
                  color: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 翻译结果显示区域
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 8 * 21.0, // 增加到8行的高度
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '正在翻译...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Text(
              '翻译结果将显示在这里',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
        child: _buildFormattedText(context),
      ),
    );
  }

  /// 构建格式化的文本显示
  Widget _buildFormattedText(BuildContext context) {
    final text = widget.text;
    
    // 检测是否为词典格式（包含音标）
    final isDictionaryFormat = text.contains('英:') && text.contains('美:');
    
    if (isDictionaryFormat) {
      return _buildDictionaryView(context, text);
    } else {
      // 普通翻译结果
      return SelectableText(
        text,
        style: const TextStyle(
          fontSize: 18, // 普通翻译字号更大
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  /// 构建词典格式视图
  Widget _buildDictionaryView(BuildContext context, String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // 音标行（英: /xxx/  美: /xxx/）
      if (line.startsWith('英:') || line.contains('美:')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
      // 词性和释义行（n. xxx）
      else if (RegExp(r'^[a-z]+\.\s+').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
      // "双语例句" 标题
      else if (line == '双语例句') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      }
      // 例句编号（1. 2.）
      else if (RegExp(r'^\d+\.\s+').hasMatch(line)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        );
      }
      // 例句翻译（缩进的行）
      else if (line.startsWith('   ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              line.trim(),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        );
      }
      // 其他内容
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
