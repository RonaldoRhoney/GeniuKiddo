import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:genius_kiddo/content/content_repository.dart';
import 'package:genius_kiddo/content/labels.dart';
import 'package:genius_kiddo/features/activities/count/count_lesson.dart';
import 'package:genius_kiddo/features/activities/letters/letters_lesson.dart';
import 'package:genius_kiddo/features/activities/rhythm/rhythm_lesson.dart';
import 'package:genius_kiddo/features/activities/shapes/shapes_lesson.dart';
import 'package:genius_kiddo/features/activities/sorting/sorting_lesson.dart';
import 'package:genius_kiddo/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Biblioteca: letras por idioma', () {
    final pt = lookupAppLocalizations(const Locale('pt'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('a letra certa sai do nome no idioma ativo (iniciais diferentes entre idiomas)', () {
      String pick(AppLocalizations l, String id) =>
          initialOf(itemName(l, id), parseLetterFold(l.letterFold));
      expect(pick(pt, 'grape'), 'U'); // uva
      expect(pick(en, 'grape'), 'G'); // grape
      expect(pick(pt, 'dog'), 'C'); // cachorro
      expect(pick(en, 'dog'), 'D');
      expect(pick(pt, 'bird'), 'P'); // passarinho
      expect(pick(en, 'bird'), 'B');
      expect(pick(pt, 'egg'), 'O'); // ovo
      expect(pick(en, 'egg'), 'E');
      expect(pick(pt, 'bee'), 'A'); // abelha
      expect(pick(en, 'bee'), 'B');
      expect(pick(pt, 'apple'), 'M'); // maçã
      expect(pick(en, 'apple'), 'A');
      expect(
        initialOf('Água', parseLetterFold(pt.letterFold)),
        'A',
      ); // sem acento
      // Regra é do idioma: sem a regra, o acento fica (ex.: ñ do espanhol).
      expect(initialOf('ñandú', parseLetterFold('á=a')), 'Ñ');
    });

    for (final (lang, l10n) in [('pt', pt), ('en', en)]) {
      test(
        '$lang: toda figura tem exatamente 1 opção certa, sem repetir, só com iniciais do mesmo idioma',
        () {
          final names = letterItems.map((id) => itemName(l10n, id)).toList();
          final fold = parseLetterFold(l10n.letterFold);
          final pool = names.map((n) => initialOf(n, fold)).toSet();
          for (final count in [3, 4]) {
            for (var seed = 0; seed < 30; seed++) {
              for (final name in names) {
                final opts = letterOptions(
                  names,
                  name,
                  count,
                  Random(seed),
                  fold,
                );
                expect(opts.length, count, reason: '$lang $name');
                expect(
                  opts.toSet().length,
                  count,
                  reason: 'repetida: $lang $name $opts',
                );
                expect(
                  opts.where((o) => o == initialOf(name, fold)).length,
                  1,
                  reason: '$lang $name $opts',
                );
                expect(
                  pool.containsAll(opts),
                  isTrue,
                  reason: 'letra de fora do idioma: $lang $opts',
                );
              }
            }
          }
        },
      );
    }

    test('toda figura da Biblioteca existe no conteúdo e tem nome nos dois idiomas', () async {
      final content = await ContentRepository.load();
      for (final id in letterItems) {
        expect(content.items.containsKey(id), isTrue, reason: id);
        expect(itemName(pt, id), isNotEmpty);
        expect(itemName(en, id), isNotEmpty);
      }
    });
  });

  test('estrutura pra novos idiomas: todo item tem nome em todos os idiomas suportados e gênero válido', () async {
    final content = await ContentRepository.load();
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final item in content.items.values) {
        expect(
          itemName(l10n, item.id),
          isNotEmpty,
          reason: '${item.id} em $locale',
        );
      }
      // A regra de acentos da Biblioteca precisa ser legível em todo idioma.
      parseLetterFold(l10n.letterFold);
    }
    for (final item in content.items.values) {
      for (final g in item.gender.values) {
        expect(['m', 'f'], contains(g), reason: item.id);
      }
      expect(item.genderIn('xx'), 'other'); // idioma sem gênero
    }
  });

  test('Sala (Anexo B): Maternal 3 formas de cor fixa; Pré I 4 formas e cores distintas; Pré II só 1 opção igual ao alvo', () {
    for (var seed = 0; seed < 50; seed++) {
      final m = shapeRound(0, Random(seed));
      expect(m.options.length, 3);
      expect(m.options.toSet(), {
        (shape: 'circle', color: 'red'),
        (shape: 'square', color: 'blue'),
        (shape: 'triangle', color: 'yellow'),
      });
      expect(m.options, contains(m.target));

      final p1 = shapeRound(1, Random(seed));
      expect(p1.options.length, 4);
      expect(p1.options.map((o) => o.shape).toSet().length, 4);
      expect(p1.options.map((o) => o.color).toSet().length, 4);
      expect(p1.options, contains(p1.target));

      final p2 = shapeRound(2, Random(seed));
      final t = p2.target;
      expect(p2.options.length, 4);
      expect(p2.options.where((o) => o == t).length, 1);
      expect(
        p2.options.any((o) => o.shape == t.shape && o.color != t.color),
        isTrue,
      );
      expect(
        p2.options.any((o) => o.shape != t.shape && o.color == t.color),
        isTrue,
      );
      expect(
        p2.options.any((o) => o.shape != t.shape && o.color != t.color),
        isTrue,
      );
    }
  });

  test('Horta (Anexo B): faixa por série, opções contêm a resposta e não repete o número anterior', () {
    final r = Random(1);
    for (final grade in [0, 1, 2]) {
      final p = countParams(grade);
      var prev = 0;
      for (var i = 0; i < 200; i++) {
        final round = countRound(grade, prev, r);
        expect(round.n, inInclusiveRange(p.min, p.max));
        expect(round.n, isNot(prev));
        expect(round.options, contains(round.n));
        expect(round.options.length, p.optionCount);
        expect(round.options.toSet().length, p.optionCount);
        expect(round.options.every((k) => k >= 1 && k <= p.maxOption), isTrue);
        prev = round.n;
      }
    }
    expect(countParams(2).optionCount, 4);
  });

  test('Pátio (Anexo B): Pré I sequências de 2 e 3; Pré II de 3 e 4', () {
    expect(rhythmLengths(1), [2, 3]);
    expect(rhythmLengths(2), [3, 4]);
  });

  test(
    'Refeitório (Anexo B): 5 itens, 3 frutas e 2 legumes, todos no conteúdo',
    () async {
      final content = await ContentRepository.load();
      for (var seed = 0; seed < 20; seed++) {
        final seq = sortingSequence(Random(seed));
        expect(seq.length, 5);
        expect(seq.where((e) => e.fruit).length, 3);
        expect(seq.map((e) => e.id).toSet().length, 5);
        for (final e in seq) {
          expect(content.items.containsKey(e.id), isTrue, reason: e.id);
          expect(sortFruits.contains(e.id), e.fruit);
        }
      }
    },
  );
}
