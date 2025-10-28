/// API配置模型
/// 用于存储和管理大模型API的配置信息
class ApiConfig {
  final String id; // 配置唯一标识
  final String name; // 大模型名称
  final String apiUrl; // API端点地址
  final String model; // 模型名称
  final String apiKey; // API密钥

  ApiConfig({
    required this.id,
    required this.name,
    required this.apiUrl,
    required this.model,
    required this.apiKey,
  });

  /// 从JSON创建配置对象
  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      apiUrl: json['apiUrl'] as String,
      model: json['model'] as String,
      apiKey: json['apiKey'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'apiUrl': apiUrl,
      'model': model,
      'apiKey': apiKey,
    };
  }

  /// 复制配置并修改部分字段
  ApiConfig copyWith({
    String? id,
    String? name,
    String? apiUrl,
    String? model,
    String? apiKey,
  }) {
    return ApiConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      apiUrl: apiUrl ?? this.apiUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  /// 验证配置是否完整
  bool isValid() {
    return name.isNotEmpty &&
        apiUrl.isNotEmpty &&
        model.isNotEmpty &&
        apiKey.isNotEmpty;
  }

  @override
  String toString() {
    return 'ApiConfig(id: $id, name: $name, model: $model)';
  }
}
