import 'package:flutter/material.dart';
import '../../models/translation_history.dart';

/// 单词标签组件
/// 用于生词本列表中显示单词
class VocabularyWordChip extends StatelessWidget {
  final TranslationHistory history;
  final Color color;
  final VoidCallback onTap;

  const VocabularyWordChip({
    super.key,
    required this.history,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          history.sourceText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}
