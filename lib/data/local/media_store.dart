import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// On-device media storage for Skill Passport photos + voice intros.
/// Everything stays in the app documents directory — no backend, no cloud.
Future<Directory> passportMediaDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/passport_media');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Copies gallery picks into durable app storage (picker cache can be
/// wiped by the OS). Returns the saved absolute paths.
Future<List<String>> persistPickedImages(List<XFile> files) async {
  final dir = await passportMediaDir();
  final out = <String>[];
  for (final f in files) {
    final safe = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final target =
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}_$safe';
    out.add((await File(f.path).copy(target)).path);
  }
  return out;
}

/// Fresh file path for a new voice-intro recording.
Future<String> nextVoicePath() async {
  final dir = await passportMediaDir();
  return '${dir.path}/voice_intro_${DateTime.now().millisecondsSinceEpoch}.m4a';
}

/// Best-effort delete; never throws.
Future<void> deleteMediaQuietly(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {}
}
