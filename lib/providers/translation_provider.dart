import 'package:flutter/foundation.dart';
import '../models/translation_history.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/api_config.dart';

/// 翻译状态管理
/// 管理翻译操作、历史记录和收藏
class TranslationProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  String _sourceText = '';
  String _translatedText = '';
  String _sourceLang = '自动';
  String _targetLang = '中文';
  bool _isTranslating = false;
  String? _errorMessage;
  
  List<TranslationHistory> _histories = [];
  List<TranslationHistory> _favorites = [];
  List<TranslationHistory> _vocabularies = [];

  TranslationProvider(this._apiService, this._storageService) {
    _loadHistories();
  }

  // Getters
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;
  List<TranslationHistory> get histories => _histories;
  /// 获取普通历史记录（不包括收藏和生词本）
  List<TranslationHistory> get normalHistories => 
      _histories.where((h) => !h.isFavorite && !h.isVocabulary).toList();
  List<TranslationHistory> get favorites => _favorites;
  List<TranslationHistory> get vocabularies => _vocabularies;
  int get wordCount => _sourceText.length;

  /// 设置源文本
  void setSourceText(String text) {
    _sourceText = text;
    notifyListeners();
  }

  /// 设置源语言
  void setSourceLang(String lang) {
    _sourceLang = lang;
    notifyListeners();
  }

  /// 设置目标语言
  void setTargetLang(String lang) {
    _targetLang = lang;
    notifyListeners();
  }

  /// 交换源语言和目标语言
  void swapLanguages() {
    // 如果源语言是"自动检测"，不执行交换
    if (_sourceLang == '自动') {
      return;
    }
    
    final temp = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = temp;
    
    // 同时交换文本
    final tempText = _sourceText;
    _sourceText = _translatedText;
    _translatedText = tempText;
    
    notifyListeners();
  }

  /// 清除输入
  void clearInput() {
    _sourceText = '';
    _translatedText = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// 执行翻译
  Future<void> translate(ApiConfig config) async {
    if (_sourceText.trim().isEmpty) {
      _errorMessage = '请输入要翻译的文本';
      notifyListeners();
      return;
    }

    if (!config.isValid()) {
      _errorMessage = 'API配置不完整';
      notifyListeners();
      return;
    }

    _isTranslating = true;
    _errorMessage = null;
    _translatedText = '';
    notifyListeners();

    try {
      final result = await _apiService.translate(
        apiUrl: config.apiUrl,
        apiKey: config.apiKey,
        model: config.model,
        sourceText: _sourceText,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      _translatedText = result;

      // 检查是否已存在相同的翻译记录
      final existingHistory = _histories.firstWhere(
        (h) => h.sourceText == _sourceText && 
               h.sourceLang == _sourceLang && 
               h.targetLang == _targetLang,
        orElse: () => TranslationHistory(
          id: '',
          sourceText: '',
          translatedText: '',
          sourceLang: '',
          targetLang: '',
          timestamp: DateTime.now(),
        ),
      );

      if (existingHistory.id.isNotEmpty) {
        // 更新已存在的记录,保留收藏和生词本状态
        final updatedHistory = existingHistory.copyWith(
          translatedText: result,
          timestamp: DateTime.now(),
        );
        await _storageService.updateHistory(updatedHistory);
      } else {
        // 创建新的历史记录
        final history = TranslationHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sourceText: _sourceText,
          translatedText: result,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          timestamp: DateTime.now(),
        );
        await _storageService.saveHistory(history);
      }
      
      await _loadHistories();
      
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  /// 从历史记录重新翻译
  Future<void> retranslateFromHistory(TranslationHistory history, ApiConfig config) async {
    _sourceText = history.sourceText;
    _sourceLang = history.sourceLang;
    _targetLang = history.targetLang;
    notifyListeners();
    
    await translate(config);
  }

  /// 加载历史记录
  Future<void> _loadHistories() async {
    try {
      _histories = await _storageService.getAllHistory();
      _favorites = await _storageService.getFavorites();
      _vocabularies = _histories.where((h) => h.isVocabulary).toList();
      notifyListeners();
    } catch (e) {
      // 加载失败时保持空列表
      _errorMessage = '加载历史记录失败';
    }
  }

  /// 刷新历史记录
  Future<void> refreshHistories() async {
    await _loadHistories();
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(TranslationHistory history) async {
    try {
      final updatedHistory = history.copyWith(isFavorite: !history.isFavorite);
      await _storageService.updateHistory(updatedHistory);
      await _loadHistories();
    } catch (e) {
      _errorMessage = '操作失败: $e';
      notifyListeners();
    }
  }

  /// 切换生词本状态
  /// 返回结果：成功返回 null，失败返回错误消息
  Future<String?> toggleVocabulary(TranslationHistory history) async {
    try {
      // 如果要加入生词本，检查是否为单词
      if (!history.isVocabulary) {
        final isWord = RegExp(r'^[a-zA-Z]+$').hasMatch(history.sourceText.trim());
        if (!isWord) {
          return '建议只将单个英文单词加入生词本，句子或短语请使用收藏功能';
        }
      }
      
      final updatedHistory = history.copyWith(isVocabulary: !history.isVocabulary);
      await _storageService.updateHistory(updatedHistory);
      await _loadHistories();
      return null; // 成功
    } catch (e) {
      return '操作失败: $e';
    }
  }

  /// 更新单词掌握程度
  Future<void> updateMasteryLevel(TranslationHistory history, int level) async {
    try {
      // 限制在 0-2 范围内
      final validLevel = level.clamp(0, 2);
      final updatedHistory = history.copyWith(masteryLevel: validLevel);
      await _storageService.updateHistory(updatedHistory);
      await _loadHistories();
    } catch (e) {
      _errorMessage = '操作失败: $e';
      notifyListeners();
    }
  }

  /// 删除历史记录
  Future<void> deleteHistory(String historyId) async {
    try {
      await _storageService.deleteHistory(historyId);
      await _loadHistories();
    } catch (e) {
      _errorMessage = '删除失败: $e';
      notifyListeners();
    }
  }

  /// 清空所有历史记录(保留收藏和生词本)
  Future<void> clearAllHistory() async {
    try {
      // 只删除未收藏且未加入生词本的记录
      final historiesToDelete = _histories
          .where((h) => !h.isFavorite && !h.isVocabulary)
          .toList();
      
      for (var history in historiesToDelete) {
        await _storageService.deleteHistory(history.id);
      }
      
      await _loadHistories();
    } catch (e) {
      _errorMessage = '清空失败: $e';
      notifyListeners();
    }
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
