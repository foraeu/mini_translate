import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';

/// 历史记录详情对话框
/// 显示完整的翻译信息，支持收藏和加入生词本
class HistoryDetailDialog extends StatelessWidget {
  final TranslationHistory history;
  final TranslationProvider provider;

  const HistoryDetailDialog({
    super.key,
    required this.history,
    required this.provider,
  });

  /// 显示对话框的静态方法
  static void show(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => HistoryDetailDialog(
          history: history,
          provider: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  '翻译详情',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 源文本
            const Text(
              '原文',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              history.sourceText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // 翻译结果
            const Text(
              '译文',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              history.translatedText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            // 元信息
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${history.sourceLang} → ${history.targetLang}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(history.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 操作按钮
            _ActionButtons(
              history: history,
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }
}

/// 对话框操作按钮
class _ActionButtons extends StatefulWidget {
  final TranslationHistory history;
  final TranslationProvider provider;

  const _ActionButtons({
    required this.history,
    required this.provider,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 生词本按钮
        TextButton.icon(
          icon: Icon(
            widget.history.isVocabulary ? Icons.book : Icons.book_outlined,
            size: 18,
            color: widget.history.isVocabulary
                ? const Color(0xFF3B82F6)
                : const Color(0xFF6B7280),
          ),
          label: Text(
            widget.history.isVocabulary ? '已加入生词本' : '加入生词本',
            style: TextStyle(
              fontSize: 13,
              color: widget.history.isVocabulary
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF6B7280),
            ),
          ),
          onPressed: () async {
            final error = await widget.provider.toggleVocabulary(widget.history);
            if (error != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            // 更新状态
            if (mounted) setState(() {});
          },
        ),
        const SizedBox(width: 8),
        // 收藏按钮
        TextButton.icon(
          icon: Icon(
            widget.history.isFavorite ? Icons.star : Icons.star_border,
            size: 18,
            color: widget.history.isFavorite
                ? Colors.amber
                : const Color(0xFF6B7280),
          ),
          label: Text(
            widget.history.isFavorite ? '已收藏' : '收藏',
            style: TextStyle(
              fontSize: 13,
              color: widget.history.isFavorite
                  ? Colors.amber[700]
                  : const Color(0xFF6B7280),
            ),
          ),
          onPressed: () {
            widget.provider.toggleFavorite(widget.history).then((_) {
              // 更新状态
              if (mounted) setState(() {});
            });
          },
        ),
      ],
    );
  }
}
