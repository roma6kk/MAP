import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  test('encrypted box: wrong key fails, compact shrinks file', () async {
    final dir = await Directory.systemTemp.createTemp('hive_t');
    Hive.init(dir.path);
    final k1 = Hive.generateSecureKey(), k2 = Hive.generateSecureKey();
    var b = await Hive.openBox<String>('t', encryptionCipher: HiveAesCipher(k1));
    for (var i = 0; i < 200; i++) {
      await b.put('k', 'value $i');
    }
    final before = File(b.path!).lengthSync();
    await b.compact();
    expect(File(b.path!).lengthSync(), lessThan(before));
    await b.close();

    b = await Hive.openBox<String>('t', encryptionCipher: HiveAesCipher(k1));
    expect(b.get('k'), 'value 199');
    await b.close();

    Object? err;
    try {
      final bad = await Hive.openBox<String>('t', encryptionCipher: HiveAesCipher(k2));
      err = 'opened, k=${bad.get('k')}, len=${bad.length}';
    } catch (e) {
      err = e;
    }
    debugPrint('wrong key result: $err');
    await dir.delete(recursive: true);
  });
}
