import 'package:dio/dio.dart';

/// API调用服务
/// 负责与大模型API进行通信
class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    // 配置Dio
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  /// 翻译文本
  /// 
  /// [apiUrl] API端点地址
  /// [apiKey] API密钥
  /// [model] 模型名称
  /// [sourceText] 待翻译文本
  /// [sourceLang] 源语言
  /// [targetLang] 目标语言
  /// 
  /// 返回翻译结果文本
  Future<String> translate({
    required String apiUrl,
    required String apiKey,
    required String model,
    required String sourceText,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      // 构建prompt
      final prompt = _buildPrompt(sourceText, sourceLang, targetLang);

      // 构建请求体（OpenAI格式）
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.3, // 降低随机性，使翻译更准确
      };

      // 发送请求
      final response = await _dio.post(
        apiUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      // 解析响应
      if (response.statusCode == 200) {
        final data = response.data;
        
        // 提取翻译结果
        if (data is Map<String, dynamic> &&
            data.containsKey('choices') &&
            data['choices'] is List &&
            (data['choices'] as List).isNotEmpty) {
          final firstChoice = (data['choices'] as List)[0];
          if (firstChoice is Map<String, dynamic> &&
              firstChoice.containsKey('message')) {
            final message = firstChoice['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('content')) {
              return message['content'] as String;
            }
          }
        }
        
        throw Exception('无法解析API响应');
      } else {
        throw Exception('API请求失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // 处理Dio异常 - 添加详细错误信息
      String errorMsg = '未知错误';
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = '请求超时(${e.type.name})';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = 'API错误 ${e.response?.statusCode}: ${e.response?.data}';
      } else if (e.type == DioExceptionType.cancel) {
        errorMsg = '请求已取消';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = '连接失败: ${e.error}';
      } else if (e.type == DioExceptionType.badCertificate) {
        errorMsg = 'SSL证书验证失败';
      } else {
        errorMsg = '${e.type.name}: ${e.message ?? e.error}';
      }
      
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('翻译失败: $e');
    }
  }

  /// 测试API连接
  /// 
  /// [apiUrl] API端点地址
  /// [apiKey] API密钥
  /// [model] 模型名称
  /// 
  /// 返回是否连接成功
  Future<bool> testConnection({
    required String apiUrl,
    required String apiKey,
    required String model,
  }) async {
    try {
      // 发送简单的测试请求
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': 'Hello',
          }
        ],
        'max_tokens': 5,
      };

      final response = await _dio.post(
        apiUrl,
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 构建翻译prompt
  String _buildPrompt(String text, String sourceLang, String targetLang) {
    // 判断是否为单个英文单词（用于词典查询）
    final trimmedText = text.trim();
    final isEnglishWord = RegExp(r'^[a-zA-Z]+$').hasMatch(trimmedText) &&
                          !trimmedText.contains(' ');
    
    // 当目标语言是中文且输入是英文单词时，提供词典信息
    if (isEnglishWord && targetLang == '中文') {
      // 单词查询模式：提供详细的词典信息
      return '''请为英语单词"$trimmedText"提供词典信息，严格按以下格式输出：

英: /英式音标/    美: /美式音标/

词性缩写.   中文释义（多个释义用分号分隔）

英文例句
例句的中文翻译

要求：
- 词性必须使用英文缩写（如 n. v. adj. adv. prep. conj. 等），不要用中文
- 只提供1个最常用的例句
- 音标使用国际音标符号
- 释义简洁准确
- 例句实用常见''';
    } else {
      // 普通翻译模式
      // 如果源语言是"自动检测"，让AI自动识别
      if (sourceLang == '自动') {
        return '''请将以下文本翻译成$targetLang，保持原意和语气：

$text''';
      } else {
        return '''请将以下文本从$sourceLang翻译成$targetLang，保持原意和语气：

$text''';
      }
    }
  }
}
