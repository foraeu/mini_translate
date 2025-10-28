import 'package:flutter/foundation.dart';
import '../models/api_config.dart';
import '../services/storage_service.dart';

/// API配置状态管理
/// 管理API配置的增删改查和当前配置的切换
class ConfigProvider with ChangeNotifier {
  final StorageService _storageService;
  
  List<ApiConfig> _configs = [];
  ApiConfig? _currentConfig;
  bool _isLoading = false;
  String? _errorMessage;

  ConfigProvider(this._storageService) {
    _loadConfigs();
  }

  // Getters
  List<ApiConfig> get configs => _configs;
  ApiConfig? get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasConfig => _currentConfig != null;

  /// 加载所有配置
  Future<void> _loadConfigs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _configs = await _storageService.getAllConfigs();
      _currentConfig = await _storageService.getCurrentConfig();
      
      // 如果没有当前配置但有配置列表，自动选择第一个
      if (_currentConfig == null && _configs.isNotEmpty) {
        await setCurrentConfig(_configs.first);
      }
    } catch (e) {
      _errorMessage = '加载配置失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 刷新配置列表
  Future<void> refreshConfigs() async {
    await _loadConfigs();
  }

  /// 添加或更新配置
  Future<void> saveConfig(ApiConfig config) async {
    try {
      await _storageService.saveConfig(config);
      await _loadConfigs();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '保存配置失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 删除配置
  Future<void> deleteConfig(String configId) async {
    try {
      await _storageService.deleteConfig(configId);
      await _loadConfigs();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '删除配置失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 设置当前使用的配置
  Future<void> setCurrentConfig(ApiConfig config) async {
    try {
      await _storageService.setCurrentConfigId(config.id);
      _currentConfig = config;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = '设置当前配置失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
