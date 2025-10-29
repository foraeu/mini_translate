import 'package:flutter/material.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';
import 'vocabulary_word_chip.dart';
import 'word_detail_dialog.dart';

/// 掌握程度分组组件
/// 显示同一掌握等级的单词列表
class VocabularyMasteryGroup extends StatelessWidget {
  final int level;
  final List<TranslationHistory> words;
  final TranslationProvider provider;

  const VocabularyMasteryGroup({
    super.key,
    required this.level,
    required this.words,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final masteryTexts = ['未学习', '学习中', '已掌握'];
    final masteryColors = [
      Colors.grey[400]!,
      Colors.orange[400]!,
      Colors.green[500]!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: masteryColors[level],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                masteryTexts[level],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: masteryColors[level],
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(3, (index) {
                return Icon(
                  index < level ? Icons.star : Icons.star_border,
                  size: 16,
                  color: index < level ? masteryColors[level] : Colors.grey[300],
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: masteryColors[level].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${words.length} 个',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: masteryColors[level],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 单词网格
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((word) {
              return VocabularyWordChip(
                history: word,
                color: masteryColors[level],
                onTap: () => WordDetailDialog.show(context, word, provider),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
