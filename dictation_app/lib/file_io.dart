import 'dart:io';

Future<String> readFileContent(String path) async {
  return await File(path).readAsString();
}
