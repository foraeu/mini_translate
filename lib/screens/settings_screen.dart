import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/config_provider.dart';
import '../models/api_config.dart';
import '../services/api_service.dart';

/// 设置页面
/// 管理API配置
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ConfigProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 当前配置
                if (provider.currentConfig != null)
                  _buildCurrentConfig(context, provider),
                
                const SizedBox(height: 24),
                
                // 配置列表
                _buildConfigList(context, provider),
                
                const SizedBox(height: 24),
                
                // 添加配置按钮
                _buildAddConfigButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建当前配置卡片
  Widget _buildCurrentConfig(BuildContext context, ConfigProvider provider) {
    final config = provider.currentConfig!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '当前配置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              config.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Model: ${config.model}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建配置列表
  Widget _buildConfigList(BuildContext context, ConfigProvider provider) {
    if (provider.configs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.settings_suggest_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '暂无配置',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击下方按钮添加API配置',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '所有配置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.configs.map((config) {
          final isCurrent = provider.currentConfig?.id == config.id;
          return _buildConfigCard(context, config, provider, isCurrent);
        }),
      ],
    );
  }

  /// 构建配置卡片
  Widget _buildConfigCard(
    BuildContext context,
    ApiConfig config,
    ConfigProvider provider,
    bool isCurrent,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrent ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isCurrent
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => provider.setCurrentConfig(config),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      config.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Model: ${config.model}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('编辑', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showConfigDialog(context, config: config),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('删除', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _deleteConfig(context, config, provider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建添加配置按钮
  Widget _buildAddConfigButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showConfigDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('添加新配置'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 显示配置对话框
  void _showConfigDialog(BuildContext context, {ApiConfig? config}) {
    showDialog(
      context: context,
      builder: (context) => ConfigDialog(config: config),
    );
  }

  /// 删除配置
  void _deleteConfig(
    BuildContext context,
    ApiConfig config,
    ConfigProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除配置"${config.name}"吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteConfig(config.id);
              Navigator.pop(context);
            },
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 配置对话框
class ConfigDialog extends StatefulWidget {
  final ApiConfig? config;

  const ConfigDialog({super.key, this.config});

  @override
  State<ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<ConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _apiUrlController;
  late TextEditingController _modelController;
  late TextEditingController _apiKeyController;
  
  bool _obscureApiKey = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _apiUrlController = TextEditingController(text: widget.config?.apiUrl ?? '');
    _modelController = TextEditingController(text: widget.config?.model ?? '');
    _apiKeyController = TextEditingController(text: widget.config?.apiKey ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.config != null;

    return AlertDialog(
      title: Text(isEdit ? '编辑配置' : '添加配置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '配置名称',
                hintText: '如: GPT-4翻译',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                hintText: 'https://api.openai.com/v1/chat/completions',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model名称',
                hintText: '如: gpt-4, claude-3-sonnet',
                prefixIcon: Icon(Icons.memory),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              keyboardType: TextInputType.visiblePassword, // 使用可见密码键盘类型
              enableSuggestions: false, // 禁用建议
              autocorrect: false, // 禁用自动更正
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: '输入API密钥',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
              obscureText: _obscureApiKey, // 保留遮罩功能但使用普通键盘
            ),
            const SizedBox(height: 16),
            // 测试连接按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(_isTesting ? '测试中...' : '测试连接'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _saveConfig,
          child: const Text('保存'),
        ),
      ],
    );
  }

  /// 测试API连接
  Future<void> _testConnection() async {
    if (_apiUrlController.text.isEmpty ||
        _apiKeyController.text.isEmpty ||
        _modelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整的配置信息')),
      );
      return;
    }

    setState(() {
      _isTesting = true;
    });

    try {
      final apiService = ApiService();
      final success = await apiService.testConnection(
        apiUrl: _apiUrlController.text,
        apiKey: _apiKeyController.text,
        model: _modelController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(success ? '连接成功!' : '连接失败，请检查配置'),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      // 捕获并显示详细的Dio错误
      String errorMsg = '连接失败';
      if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'API错误 ${e.response?.statusCode}: ${e.response?.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = '连接超时,请检查网络';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = '网络连接失败: ${e.error}';
      } else {
        errorMsg = '${e.type.name}: ${e.message ?? e.error}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  /// 保存配置
  void _saveConfig() {
    if (_nameController.text.isEmpty ||
        _apiUrlController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整的配置信息')),
      );
      return;
    }

    final config = ApiConfig(
      id: widget.config?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      apiUrl: _apiUrlController.text,
      model: _modelController.text,
      apiKey: _apiKeyController.text,
    );

    Provider.of<ConfigProvider>(context, listen: false).saveConfig(config);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配置已保存')),
    );
  }
}
