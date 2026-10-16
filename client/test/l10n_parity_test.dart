import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Seção 10 da especificação: "chaves de texto iguais nos dois idiomas;
/// teste automatizado falha se faltar tradução." Roda sobre os ARB de
/// verdade (lib/l10n/*.arb), não uma cópia — qualquer chave nova em um
/// precisa existir no outro antes do commit passar.
void main() {
  test('app_pt.arb e app_en.arb têm exatamente o mesmo conjunto de chaves', () {
    final pt = _keysOf('lib/l10n/app_pt.arb');
    final en = _keysOf('lib/l10n/app_en.arb');

    final onlyInPt = pt.difference(en);
    final onlyInEn = en.difference(pt);

    expect(
      onlyInPt,
      isEmpty,
      reason: 'chaves em app_pt.arb sem tradução em app_en.arb: $onlyInPt',
    );
    expect(
      onlyInEn,
      isEmpty,
      reason: 'chaves em app_en.arb sem equivalente em app_pt.arb: $onlyInEn',
    );
  });
}

Set<String> _keysOf(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}
