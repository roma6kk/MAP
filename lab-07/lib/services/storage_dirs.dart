import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/developer.dart';

enum Plat { android, ios, macos, linux, windows, other }

Plat get currentPlatform {
  if (Platform.isAndroid) return Plat.android;
  if (Platform.isIOS) return Plat.ios;
  if (Platform.isMacOS) return Plat.macos;
  if (Platform.isLinux) return Plat.linux;
  if (Platform.isWindows) return Plat.windows;
  return Plat.other;
}

class DirSpec {
  const DirSpec(this.title, this.supported, this.resolve);
  final String title;
  final Set<Plat> supported;

  final Future<List<Directory?>> Function() resolve;
}

class DirResult {
  DirResult(this.spec, {this.directory, this.error, this.content});
  final DirSpec spec;
  final Directory? directory;
  final String? error;
  final Developer? content;
}

const _all = {Plat.android, Plat.ios, Plat.macos, Plat.linux, Plat.windows};
const _apple = {Plat.ios, Plat.macos};
const _android = {Plat.android};

final dirSpecs = <DirSpec>[
  DirSpec('Temporary', _all, () async => [await getTemporaryDirectory()]),
  DirSpec(
    'Application Support',
    _all,
    () async => [await getApplicationSupportDirectory()],
  ),
  DirSpec(
    'Application Library',
    _apple,
    () async => [await getLibraryDirectory()],
  ),
  DirSpec(
    'Application Documents',
    _all,
    () async => [await getApplicationDocumentsDirectory()],
  ),
  DirSpec(
    'Application Cache',
    _all,
    () async => [await getApplicationCacheDirectory()],
  ),
  DirSpec(
    'External Storage',
    _android,
    () async => [await getExternalStorageDirectory()],
  ),
  DirSpec(
    'External Cache Directories',
    _android,
    () async => await getExternalCacheDirectories() ?? [],
  ),
  DirSpec(
    'External Storage Directories',
    _android,
    () async => await getExternalStorageDirectories() ?? [],
  ),
  DirSpec('Downloads', {
    Plat.android,
    Plat.ios,
    Plat.macos,
    Plat.linux,
    Plat.windows,
  }, () async => [await getDownloadsDirectory()]),
];

String _platName(Plat p) => switch (p) {
  Plat.android => 'Android',
  Plat.ios => 'iOS',
  Plat.macos => 'macOS',
  Plat.linux => 'Linux',
  Plat.windows => 'Windows',
  Plat.other => 'неизвестная платформа',
};

String unsupportedMessage(DirSpec spec, Object? cause) {
  final here = _platName(currentPlatform);
  final ok = spec.supported.map(_platName).join(', ');
  final unsupported = Plat.values
      .where((p) => p != Plat.other && !spec.supported.contains(p))
      .map(_platName)
      .join(', ');
  return '«${spec.title}» не поддерживается на $here. '
      'Поддерживается: $ok. Не поддерживается: $unsupported.'
      '${cause == null ? '' : '\nПричина: $cause'}';
}

Developer sampleFor(DirSpec spec, int index) => Developer(
  id: index,
  name: 'Dev из «${spec.title}»',
  specialty: index.isEven ? 'Flutter / Dart' : 'Backend / API',
  role: Developer.roles[index % 2],
  salary: 100000.0 + index * 12500,
  cupsOfCoffee: index + 1,
);

Future<DirResult> writeAndRead(DirSpec spec, int index) async {
  if (!spec.supported.contains(currentPlatform)) {
    return DirResult(spec, error: unsupportedMessage(spec, null));
  }
  try {
    final dirs = await spec.resolve();
    final dir = dirs.whereType<Directory>().firstOrNull;
    if (dir == null) {
      return DirResult(
        spec,
        error: unsupportedMessage(spec, 'платформа вернула null'),
      );
    }
    await dir.create(recursive: true);
    final file = File(
      '${dir.path}${Platform.pathSeparator}developer_$index.json',
    );
    final dev = sampleFor(spec, index);
    await file.writeAsString(jsonEncode(dev.toJson()));
    final read = Developer.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
    return DirResult(spec, directory: dir, content: read);
  } on UnsupportedError catch (e) {
    return DirResult(spec, error: unsupportedMessage(spec, e.message));
  } on MissingPlatformDirectoryException catch (e) {
    return DirResult(spec, error: unsupportedMessage(spec, e.message));
  } on FileSystemException catch (e) {
    return DirResult(
      spec,
      error:
          'Ошибка файловой системы (${_platName(currentPlatform)}): '
          '${e.message} ${e.path ?? ''}',
    );
  } catch (e) {
    return DirResult(spec, error: 'Ошибка: $e');
  }
}
