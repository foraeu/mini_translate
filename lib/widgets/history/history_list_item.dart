import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/translation_history.dart';

/// 简洁的历史记录列表项
/// 用于"全部"标签页的简洁列表显示
class HistoryListItem extends StatelessWidget {
  final TranslationHistory history;
  final VoidCallback onTap;

  const HistoryListItem({
    super.key,
    required this.history,
    required this.onTap,
  });

  /// 清理文本中的多余空行
  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\n\s*\n+'), '\n');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.sourceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cleanText(history.translatedText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              dateFormat.format(history.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
