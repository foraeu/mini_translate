/// 翻译历史记录模型
/// 用于存储用户的翻译历史和收藏
class TranslationHistory {
  final String id; // 记录唯一标识
  final String sourceText; // 源文本
  final String translatedText; // 翻译结果
  final String sourceLang; // 源语言
  final String targetLang; // 目标语言
  final DateTime timestamp; // 翻译时间
  final bool isFavorite; // 是否收藏
  final bool isVocabulary; // 是否加入生词本
  final int masteryLevel; // 掌握程度 0-2 (0=未学习, 1=学习中, 2=已掌握)

  TranslationHistory({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.isFavorite = false,
    this.isVocabulary = false,
    this.masteryLevel = 0,
  });

  /// 从JSON创建历史记录对象
  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLang: json['sourceLang'] as String,
      targetLang: json['targetLang'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isVocabulary: json['isVocabulary'] as bool? ?? false,
      masteryLevel: json['masteryLevel'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
      'isVocabulary': isVocabulary,
      'masteryLevel': masteryLevel,
    };
  }

  /// 复制记录并修改部分字段
  TranslationHistory copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    DateTime? timestamp,
    bool? isFavorite,
    bool? isVocabulary,
    int? masteryLevel,
  }) {
    return TranslationHistory(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      isVocabulary: isVocabulary ?? this.isVocabulary,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  @override
  String toString() {
    return 'TranslationHistory($sourceLang -> $targetLang, ${sourceText.substring(0, sourceText.length > 20 ? 20 : sourceText.length)}...)';
  }
}
