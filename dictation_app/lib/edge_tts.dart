import 'dart:js' as js;

/// Enhanced TTS for Web Platform
/// 使用浏览器 speechSynthesis API，自动选择最佳中文语音
class EdgeTTS {
  /// 播放文本
  static Future<void> speak(String text, {String voice = '', double rate = 1.0}) async {
    try {
      js.context.callMethod('speakText', [text, rate]);
      // 估算播放时间并等待
      final duration = Duration(milliseconds: (text.length * 180 / rate).round());
      await Future.delayed(duration);
    } catch (e) {
      // 静默处理错误
    }
  }

  static void stop() {
    try {
      js.context.callMethod('stopSpeaking');
    } catch (e) {
      // 静默处理错误
    }
  }
}
