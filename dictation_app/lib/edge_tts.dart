import 'dart:js_interop';

/// Enhanced TTS for Web Platform
/// 使用浏览器 speechSynthesis API，自动选择最佳中文语音
@JS()
external void speakText(JSString text, double rate);

@JS()
external void stopSpeaking();

class EdgeTTS {
  /// 播放文本
  static Future<void> speak(String text, {String voice = '', double rate = 1.0}) async {
    try {
      // 使用 dart:js_interop 调用全局 JavaScript 函数
      speakText(text.toJS, rate);
      // 估算播放时间并等待
      final duration = Duration(milliseconds: (text.length * 180 / rate).round());
      await Future.delayed(duration);
    } catch (e) {
      // 静默处理错误
    }
  }

  static void stop() {
    try {
      stopSpeaking();
    } catch (e) {
      // 静默处理错误
    }
  }
}
