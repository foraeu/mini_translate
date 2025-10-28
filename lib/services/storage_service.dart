import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_config.dart';
import '../models/translation_history.dart';

/// 本地存储服务
/// 负责管理应用的本地数据持久化
class StorageService {
  static const String _configsKey = 'api_configs';
  static const String _currentConfigIdKey = 'current_config_id';
  static const String _historyKey = 'translation_history';
  static const String _apiKeysPrefix = 'api_key_';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService._(this._prefs, this._secureStorage);

  /// 初始化存储服务
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    return StorageService._(prefs, secureStorage);
  }

  // ==================== API配置管理 ====================

  /// 保存API配置
  Future<void> saveConfig(ApiConfig config) async {
    final configs = await getAllConfigs();
    
    // 检查是否已存在该配置
    final index = configs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      configs[index] = config;
    } else {
      configs.add(config);
    }

    // 保存配置列表（不包含API Key）
    final configsJson = configs.map((c) {
      final json = c.toJson();
      json.remove('apiKey'); // 从普通存储中移除API Key
      return json;
    }).toList();
    
    await _prefs.setString(_configsKey, jsonEncode(configsJson));

    // 安全存储API Key
    await _secureStorage.write(
      key: '$_apiKeysPrefix${config.id}',
      value: config.apiKey,
    );
  }

  /// 获取所有API配置
  Future<List<ApiConfig>> getAllConfigs() async {
    final configsStr = _prefs.getString(_configsKey);
    if (configsStr == null || configsStr.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> configsList = jsonDecode(configsStr);
      final configs = <ApiConfig>[];

      for (var configJson in configsList) {
        if (configJson is Map<String, dynamic>) {
          final id = configJson['id'] as String;
          // 从安全存储中读取API Key
          final apiKey = await _secureStorage.read(key: '$_apiKeysPrefix$id') ?? '';
          configJson['apiKey'] = apiKey;
          configs.add(ApiConfig.fromJson(configJson));
        }
      }

      return configs;
    } catch (e) {
      // 解析失败返回空列表
      return [];
    }
  }

  /// 删除API配置
  Future<void> deleteConfig(String configId) async {
    final configs = await getAllConfigs();
    configs.removeWhere((c) => c.id == configId);

    // 保存更新后的配置列表
    final configsJson = configs.map((c) {
      final json = c.toJson();
      json.remove('apiKey');
      return json;
    }).toList();
    
    await _prefs.setString(_configsKey, jsonEncode(configsJson));

    // 删除API Key
    await _secureStorage.delete(key: '$_apiKeysPrefix$configId');

    // 如果删除的是当前配置，清除当前配置ID
    final currentId = await getCurrentConfigId();
    if (currentId == configId) {
      await _prefs.remove(_currentConfigIdKey);
    }
  }

  /// 设置当前使用的配置
  Future<void> setCurrentConfigId(String configId) async {
    await _prefs.setString(_currentConfigIdKey, configId);
  }

  /// 获取当前使用的配置ID
  Future<String?> getCurrentConfigId() async {
    return _prefs.getString(_currentConfigIdKey);
  }

  /// 获取当前使用的配置
  Future<ApiConfig?> getCurrentConfig() async {
    final configId = await getCurrentConfigId();
    if (configId == null) return null;

    final configs = await getAllConfigs();
    try {
      return configs.firstWhere((c) => c.id == configId);
    } catch (e) {
      return null;
    }
  }

  // ==================== 翻译历史管理 ====================

  /// 保存翻译历史
  Future<void> saveHistory(TranslationHistory history) async {
    final histories = await getAllHistory();
    
    // 添加到列表开头（最新的在前）
    histories.insert(0, history);

    // 限制历史记录数量（保留最近100条）
    if (histories.length > 100) {
      histories.removeRange(100, histories.length);
    }

    final historiesJson = histories.map((h) => h.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(historiesJson));
  }

  /// 获取所有翻译历史
  Future<List<TranslationHistory>> getAllHistory() async {
    final historyStr = _prefs.getString(_historyKey);
    if (historyStr == null || historyStr.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> historyList = jsonDecode(historyStr);
      return historyList
          .whereType<Map<String, dynamic>>()
          .map((item) => TranslationHistory.fromJson(item))
          .toList();
    } catch (e) {
      // 解析失败返回空列表
      return [];
    }
  }

  /// 获取收藏的翻译
  Future<List<TranslationHistory>> getFavorites() async {
    final histories = await getAllHistory();
    return histories.where((h) => h.isFavorite).toList();
  }

  /// 更新翻译历史（用于切换收藏状态）
  Future<void> updateHistory(TranslationHistory history) async {
    final histories = await getAllHistory();
    final index = histories.indexWhere((h) => h.id == history.id);
    
    if (index >= 0) {
      histories[index] = history;
      final historiesJson = histories.map((h) => h.toJson()).toList();
      await _prefs.setString(_historyKey, jsonEncode(historiesJson));
    }
  }

  /// 删除翻译历史
  Future<void> deleteHistory(String historyId) async {
    final histories = await getAllHistory();
    histories.removeWhere((h) => h.id == historyId);
    
    final historiesJson = histories.map((h) => h.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(historiesJson));
  }

  /// 清空所有翻译历史
  Future<void> clearAllHistory() async {
    await _prefs.remove(_historyKey);
  }
}
