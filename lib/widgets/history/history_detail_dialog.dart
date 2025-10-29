import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';

/// 历史记录详情对话框
/// 显示完整的翻译信息，支持收藏和加入生词本
class HistoryDetailDialog extends StatelessWidget {
  final String historyId;

  const HistoryDetailDialog({
    super.key,
    required this.historyId,
  });

  /// 显示对话框的静态方法
  static void show(
    BuildContext context,
    TranslationHistory history,
    TranslationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => HistoryDetailDialog(
        historyId: history.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslationProvider>(
      builder: (context, provider, child) {
        // 从 provider 中获取最新的 history 对象
        final history = provider.histories.firstWhere(
          (h) => h.id == historyId,
          orElse: () => provider.favorites.firstWhere(
            (h) => h.id == historyId,
            orElse: () => provider.vocabularies.firstWhere(
              (h) => h.id == historyId,
            ),
          ),
        );
        
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 生词本按钮
                    TextButton.icon(
                      icon: Icon(
                        history.isVocabulary ? Icons.book : Icons.book_outlined,
                        size: 18,
                        color: history.isVocabulary
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                      ),
                      label: Text(
                        history.isVocabulary ? '已加入生词本' : '加入生词本',
                        style: TextStyle(
                          fontSize: 13,
                          color: history.isVocabulary
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      onPressed: () async {
                        final error = await provider.toggleVocabulary(history);
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    // 收藏按钮
                    TextButton.icon(
                      icon: Icon(
                        history.isFavorite ? Icons.star : Icons.star_border,
                        size: 18,
                        color: history.isFavorite
                            ? Colors.amber
                            : const Color(0xFF6B7280),
                      ),
                      label: Text(
                        history.isFavorite ? '已收藏' : '收藏',
                        style: TextStyle(
                          fontSize: 13,
                          color: history.isFavorite
                              ? Colors.amber[700]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      onPressed: () {
                        provider.toggleFavorite(history);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
