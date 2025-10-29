import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';
import 'mastery_indicator.dart';

/// 单词详情对话框
/// 显示单词的详细信息，包括翻译、掌握程度等
class WordDetailDialog extends StatelessWidget {
  final TranslationHistory history;
  final TranslationProvider provider;

  const WordDetailDialog({
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
      builder: (context) => WordDetailDialog(
        history: history,
        provider: provider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                children: [
                  Expanded(
                    child: Text(
                      history.sourceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 语言方向和时间
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${history.sourceLang} → ${history.targetLang}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateFormat.format(history.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // 翻译内容
              Text(
                '翻译',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                history.translatedText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              // 掌握程度
              MasteryIndicator(
                history: history,
                provider: provider,
              ),
              const SizedBox(height: 20),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.toggleFavorite(history);
                      },
                      icon: Icon(
                        history.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                      ),
                      label: Text(history.isFavorite ? '已收藏' : '收藏'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: history.isFavorite ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final error = await provider.toggleVocabulary(history);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('移出生词本'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
