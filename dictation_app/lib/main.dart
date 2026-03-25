import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'file_io_stub.dart'
    if (dart.library.io) 'file_io.dart';
import 'default_words.dart';
import 'edge_tts_stub.dart'
    if (dart.library.js) 'edge_tts.dart';

void main() {
  runApp(const DictationApp());
}

class DictationApp extends StatelessWidget {
  const DictationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '字词听写',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<String> _words = [];
  final Set<String> _selectedWords = {};
  double _interval = 5.0;
  int _repeatCount = 2;

  @override
  void initState() {
    super.initState();
    // 加载预置字词
    _words.addAll(defaultWords);
    // 默认全选
    _selectedWords.addAll(defaultWords);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SettingsScreen(
            words: _words,
            selectedWords: _selectedWords,
            interval: _interval,
            repeatCount: _repeatCount,
            onWordsChanged: (newWords) {
              setState(() {
                _words.clear();
                _words.addAll(newWords);
                _selectedWords.clear();
                _selectedWords.addAll(newWords);
              });
            },
            onSelectedWordsChanged: (words) {
              setState(() {
                _selectedWords.clear();
                _selectedWords.addAll(words);
              });
            },
            onIntervalChanged: (newInterval) => setState(() => _interval = newInterval),
            onRepeatCountChanged: (count) => setState(() => _repeatCount = count),
          ),
          DictationScreen(
            words: _words,
            selectedWords: _selectedWords,
            interval: _interval,
            repeatCount: _repeatCount,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: isSmallScreen ? 60 : 80,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          NavigationDestination(icon: Icon(Icons.headphones), label: '听写'),
        ],
      ),
    );
  }
}

// 设置页面
class SettingsScreen extends StatefulWidget {
  final List<String> words;
  final Set<String> selectedWords;
  final double interval;
  final int repeatCount;
  final Function(List<String>) onWordsChanged;
  final Function(Set<String>) onSelectedWordsChanged;
  final Function(double) onIntervalChanged;
  final Function(int) onRepeatCountChanged;

  const SettingsScreen({
    super.key,
    required this.words,
    required this.selectedWords,
    required this.interval,
    required this.repeatCount,
    required this.onWordsChanged,
    required this.onSelectedWordsChanged,
    required this.onIntervalChanged,
    required this.onRepeatCountChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('字词列表', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
                        Text('已选 ${widget.selectedWords.length}/${widget.words.length}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    // 选择操作按钮
                    if (widget.words.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              widget.onSelectedWordsChanged(Set.from(widget.words));
                              setState(() {});
                            },
                            icon: const Icon(Icons.select_all, size: 16),
                            label: const Text('全选'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              widget.onSelectedWordsChanged({});
                              setState(() {});
                            },
                            icon: const Icon(Icons.deselect, size: 16),
                            label: const Text('清空选择'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              final newSelection = <String>{};
                              for (final word in widget.words) {
                                if (!widget.selectedWords.contains(word)) {
                                  newSelection.add(word);
                                }
                              }
                              widget.onSelectedWordsChanged(newSelection);
                              setState(() {});
                            },
                            icon: const Icon(Icons.flip, size: 16),
                            label: const Text('反选'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    if (widget.words.isEmpty)
                      const Text('请导入字词文件', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.words.map((word) {
                          final isSelected = widget.selectedWords.contains(word);
                          return FilterChip(
                            label: Text(word, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newSelection = Set<String>.from(widget.selectedWords);
                              if (selected) {
                                newSelection.add(word);
                              } else {
                                newSelection.remove(word);
                              }
                              widget.onSelectedWordsChanged(newSelection);
                              setState(() {});
                            },
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue,
                            backgroundColor: Colors.grey.shade100,
                          );
                        }).toList(),
                      ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _importFile,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('导入文件'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 8 : 12),
                          ),
                        ),
                        if (widget.words.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.onWordsChanged([]);
                              widget.onSelectedWordsChanged({});
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('清空列表'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 8 : 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('听写间隔', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: widget.interval,
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '${widget.interval.toInt()}秒',
                            onChanged: (value) {
                              widget.onIntervalChanged(value);
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            controller: TextEditingController(text: widget.interval.toInt().toString()),
                            onSubmitted: (value) {
                              final num = double.tryParse(value);
                              if (num != null && num >= 1 && num <= 30) {
                                widget.onIntervalChanged(num);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 2 : 4),
                        const Text('秒'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('朗读重复次数', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text('每个词重复朗读的次数', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: widget.repeatCount.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: '${widget.repeatCount}次',
                            onChanged: (value) {
                              widget.onRepeatCountChanged(value.toInt());
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            controller: TextEditingController(text: widget.repeatCount.toString()),
                            onSubmitted: (value) {
                              final num = int.tryParse(value);
                              if (num != null && num >= 1 && num <= 5) {
                                widget.onRepeatCountChanged(num);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 2 : 4),
                        const Text('次'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            // 语音测试卡片
            Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('语音测试', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text('如果没有声音，请点击下方按钮测试语音', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    ElevatedButton.icon(
                      onPressed: _testVoice,
                      icon: const Icon(Icons.volume_up, size: 18),
                      label: const Text('测试语音'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 10 : 12),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text('提示：首次使用需要点击页面任意位置来激活语音', style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.orange)),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('文件格式说明', style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• TXT文件：每行一个字词', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                    Text('• JSON文件：["字词1", "字词2", ...]', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'json'],
    );

    if (result != null && result.files.isNotEmpty) {
      List<String> newWords = [];
      String content = '';

      // Web 平台使用 bytes，移动端使用 path
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          content = utf8.decode(bytes);
        }
      } else {
        final path = result.files.single.path;
        if (path != null) {
          // 使用条件导入避免 Web 平台导入 dart:io
          content = await _readFileContent(path);
        }
      }

      if (content.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文件读取失败')),
        );
        return;
      }

      // 解析文件内容
      if (result.files.single.name.endsWith('.json')) {
        try {
          final decoded = jsonDecode(content);
          newWords = List<String>.from(decoded);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('JSON格式错误: $e')),
          );
          return;
        }
      } else {
        newWords = content
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      if (newWords.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文件中没有找到有效的字词')),
        );
        return;
      }

      widget.onWordsChanged(newWords);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导入 ${newWords.length} 个字词')),
      );
    }
  }

  // 条件导入的辅助函数
  Future<String> _readFileContent(String path) async {
    return readFileContent(path);
  }

  // 测试语音
  Future<void> _testVoice() async {
    if (kIsWeb) {
      await EdgeTTS.speak('语音测试成功');
    } else {
      final flutterTts = FlutterTts();
      await flutterTts.setLanguage('zh-CN');
      await flutterTts.speak('语音测试成功');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('如果听到声音说明语音正常'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// 听写页面
class DictationScreen extends StatefulWidget {
  final List<String> words;
  final Set<String> selectedWords;
  final double interval;
  final int repeatCount;

  const DictationScreen({
    super.key,
    required this.words,
    required this.selectedWords,
    required this.interval,
    required this.repeatCount,
  });

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _showWord = false;
  Timer? _timer;
  Timer? _progressTimer;
  int _remainingSeconds = 0;
  int _currentRepeat = 1; // 当前重复次数
  bool get _useEdgeTTS => kIsWeb;

  // 获取实际的听写字词列表（只包含选中的）
  List<String> get _activeWords {
    return widget.words.where((word) => widget.selectedWords.contains(word)).toList();
  }

  @override
  void initState() {
    super.initState();
    if (!_useEdgeTTS) {
      _initTts();
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    if (!_useEdgeTTS) {
      _flutterTts.stop();
    }
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_useEdgeTTS) {
      await EdgeTTS.speak(text, voice: 'zh-CN-XiaoxiaoNeural', rate: 1.0);
    } else {
      await _flutterTts.speak(text);
    }
  }

  void _play() {
    if (_activeWords.isEmpty) return;
    setState(() {
      _isPlaying = true;
      _currentRepeat = 1;
    });
    _showCurrentWord();
    _scheduleNext();
  }

  void _pause() {
    _timer?.cancel();
    _progressTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _remainingSeconds = 0;
    });
  }

  void _scheduleNext() {
    _timer?.cancel();
    _progressTimer?.cancel();

    final interval = widget.interval.toInt();
    setState(() => _remainingSeconds = interval);

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && mounted) {
        setState(() => _remainingSeconds--);
      }
    });

    _timer = Timer(Duration(seconds: interval), () {
      _progressTimer?.cancel();
      if (_isPlaying && mounted) {
        _afterInterval();
      }
    });
  }

  void _afterInterval() {
    // 倒计时结束后，检查是否需要重复
    if (_currentRepeat < widget.repeatCount) {
      // 继续重复当前词
      setState(() => _currentRepeat++);
      _showCurrentWord();
      _scheduleNext();
    } else {
      // 重复完成，进入下一个词
      _moveToNextWord();
    }
  }

  void _showCurrentWord() {
    setState(() => _showWord = false);
    _speak(_activeWords[_currentIndex]);
  }

  void _moveToNextWord() {
    if (_currentIndex < _activeWords.length - 1) {
      setState(() {
        _currentIndex++;
        _currentRepeat = 1;
      });
      _showCurrentWord();
      if (_isPlaying) _scheduleNext();
    } else {
      _pause();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('听写完成！')),
      );
    }
  }

  void _next() {
    // 手动点击下一个按钮时，直接跳到下一个词
    if (_currentIndex < _activeWords.length - 1) {
      setState(() {
        _currentIndex++;
        _currentRepeat = 1;
      });
      _showCurrentWord();
      if (_isPlaying) _scheduleNext();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentRepeat = 1;
      });
      _showCurrentWord();
      if (_isPlaying) _scheduleNext();
    }
  }

  void _reset() {
    _pause();
    setState(() {
      _currentIndex = 0;
      _showWord = false;
      _remainingSeconds = 0;
      _currentRepeat = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasWords = _activeWords.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final boxSize = isSmallScreen ? 150.0 : 200.0;
    final fontSize = isSmallScreen ? 28.0 : 36.0;
    final buttonSize = isSmallScreen ? 45.0 : 56.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('听写'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (hasWords)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: '重新开始',
            ),
        ],
      ),
      body: !hasWords
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: isSmallScreen ? 48 : 64, color: Colors.grey),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text('请先在设置中导入字词', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.grey)),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 140),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_currentIndex + 1} / ${_activeWords.length}',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.grey),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        Container(
                          width: boxSize,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: _showWord ? Colors.blue.shade50 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Center(
                            child: _showWord
                                ? Text(
                                    _activeWords[_currentIndex],
                                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    '???',
                                    style: TextStyle(fontSize: fontSize, color: Colors.grey),
                                  ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        TextButton.icon(
                          onPressed: () => setState(() => _showWord = !_showWord),
                          icon: Icon(_showWord ? Icons.visibility_off : Icons.visibility),
                          label: Text(_showWord ? '隐藏答案' : '显示答案'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: FloatingActionButton(
                                heroTag: 'prev',
                                onPressed: _currentIndex > 0 ? _previous : null,
                                child: Icon(Icons.skip_previous, size: iconSize),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 16 : 20),
                            SizedBox(
                              width: buttonSize * 1.2,
                              height: buttonSize * 1.2,
                              child: FloatingActionButton(
                                heroTag: 'play',
                                backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                                onPressed: () {
                                  if (_isPlaying) {
                                    _pause();
                                  } else {
                                    _play();
                                  }
                                },
                                child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: iconSize * 1.2),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 16 : 20),
                            SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: FloatingActionButton(
                                heroTag: 'next',
                                onPressed: _currentIndex < _activeWords.length - 1 ? _next : null,
                                child: Icon(Icons.skip_next, size: iconSize),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 32),
                        // 进度条
                        if (_isPlaying)
                          Column(
                            children: [
                              SizedBox(
                                width: boxSize * 1.5,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('进度', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                                        Text('$_remainingSeconds秒', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: (widget.interval.toInt() - _remainingSeconds) / widget.interval.toInt(),
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(_isPlaying ? Colors.blue : Colors.grey),
                                      minHeight: isSmallScreen ? 6 : 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: isSmallScreen ? 20 : 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
