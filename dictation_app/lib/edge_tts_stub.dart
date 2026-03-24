// Stub for non-Web platforms
class EdgeTTS {
  static Future<List<String>> getVoices() => Future.value([]);
  static Future<void> speak(String text, {String voice = 'zh-CN-XiaoxiaoNeural', double rate = 1.0}) async {
    throw UnimplementedError('Edge TTS only available on Web platform');
  }
  static void stop() {}
}
