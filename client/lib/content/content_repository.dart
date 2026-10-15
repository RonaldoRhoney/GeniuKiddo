import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

class ContentRepository {
  const ContentRepository({required this.items, required this.trail});

  final Map<String, ItemDef> items;
  final List<TrailNodeDef> trail;

  ItemDef item(String id) => items[id] ?? (throw StateError('item desconhecido: $id'));

  static Future<ContentRepository> load() async {
    final itemsRaw = jsonDecode(await rootBundle.loadString('assets/content/items.json')) as Map<String, dynamic>;
    final trailRaw = jsonDecode(await rootBundle.loadString('assets/content/trail.json')) as List<dynamic>;
    return ContentRepository(
      items: {for (final e in itemsRaw.entries) e.key: ItemDef.fromJson(e.key, e.value as Map<String, dynamic>)},
      trail: trailRaw.map((e) => TrailNodeDef.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Sobrescrito em `main.dart` depois do `ContentRepository.load()`
/// assíncrono — nunca lido antes disso (mesmo padrão de persistenceServiceProvider).
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => throw UnimplementedError('contentRepositoryProvider precisa de override em main.dart'),
);
