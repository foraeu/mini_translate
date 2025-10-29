import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/translation_history.dart';
import '../../providers/translation_provider.dart';
import 'mastery_indicator.dart';

/// 单词详情对话框
/// 显示单词的详细信息，包括翻译、掌握程度等
class WordDetailDialog extends StatefulWidget {
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
  State<WordDetailDialog> createState() => _WordDetailDialogState();
}

class _WordDetailDialogState extends State<WordDetailDialog> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  /// 初始化 TTS
  void _initTts() {
    _flutterTts = FlutterTts();
    
    // 配置 TTS
    _flutterTts.setLanguage('en-US'); // 设置为美式英语
    _flutterTts.setSpeechRate(0.5); // 语速：0.5 = 正常速度
    _flutterTts.setVolume(1.0); // 音量：1.0 = 最大
    _flutterTts.setPitch(1.0); // 音调：1.0 = 正常
    
    // 监听朗读状态
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
    
    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('朗读失败: $msg'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  /// 朗读单词
  Future<void> _speak() async {
    if (_isSpeaking) {
      // 如果正在朗读，则停止
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      // 开始朗读
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(widget.history.sourceText);
    }
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
              // 标题栏（单词 + 朗读按钮）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.history.sourceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // TTS 朗读按钮
                  IconButton(
                    icon: Icon(
                      _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                      color: _isSpeaking ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                    ),
                    onPressed: _speak,
                    tooltip: _isSpeaking ? '停止朗读' : '朗读单词',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
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
                      '${widget.history.sourceLang} → ${widget.history.targetLang}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateFormat.format(widget.history.timestamp),
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
                widget.history.translatedText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              // 掌握程度
              MasteryIndicator(
                history: widget.history,
                provider: widget.provider,
              ),
              const SizedBox(height: 20),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.provider.toggleFavorite(widget.history);
                      },
                      icon: Icon(
                        widget.history.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                      ),
                      label: Text(widget.history.isFavorite ? '已收藏' : '收藏'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.history.isFavorite ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final error = await widget.provider.toggleVocabulary(widget.history);
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
