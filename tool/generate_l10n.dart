import 'dart:convert';
import 'dart:io';

String _joinPath(List<String> parts) {
  return parts.join(Platform.pathSeparator);
}

Future<Map<String, dynamic>> _mergeLocaleArbs({
  required Directory featureDir,
  required String locale,
}) async {
  final files = featureDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('_$locale.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    throw StateError("No ARB files found for locale '$locale'.");
  }

  final merged = <String, dynamic>{'@@locale': locale};

  for (final file in files) {
    final content = await file.readAsString(encoding: utf8);
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Expected ARB map in ${file.path}.');
    }

    for (final entry in decoded.entries) {
      merged[entry.key] = entry.value;
    }
  }

  return merged;
}

Future<void> main() async {
  final root = Directory.current;
  final arbDir = Directory(_joinPath([root.path, 'lib', 'l10n']));
  final featureDir = Directory(_joinPath([arbDir.path, 'features']));
  final outputFiles = <File>[
    File(_joinPath([arbDir.path, 'app_en.arb'])),
    File(_joinPath([arbDir.path, 'app_pl.arb'])),
  ];

  stdout.writeln('Merging split ARB files...');

  final en = await _mergeLocaleArbs(featureDir: featureDir, locale: 'en');
  final pl = await _mergeLocaleArbs(featureDir: featureDir, locale: 'pl');

  const encoder = JsonEncoder.withIndent('  ');
  await outputFiles[0].writeAsString(
    '${encoder.convert(en)}\n',
    encoding: utf8,
  );
  await outputFiles[1].writeAsString(
    '${encoder.convert(pl)}\n',
    encoding: utf8,
  );

  stdout.writeln('Running flutter gen-l10n...');
  final result = await Process.run(
    'flutter',
    ['gen-l10n'],
    workingDirectory: root.path,
    runInShell: true,
  );

  if (result.stdout case final Object stdoutText?) {
    stdout.write(stdoutText);
  }
  if (result.stderr case final Object stderrText?) {
    stderr.write(stderrText);
  }

  if (result.exitCode != 0) {
    exitCode = result.exitCode;
  }
}
