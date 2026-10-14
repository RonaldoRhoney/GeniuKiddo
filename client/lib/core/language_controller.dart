import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'persistence_service.dart';

/// Estado de idioma (seção 4.5): um idioma por vez, nunca misturado.
/// `isFirstChoice` distingue a fala `welcomeFirst` (Anexo C) de
/// `welcomeBack` — true só quando não havia idioma salvo ANTES desta sessão
/// abrir (primeira execução de verdade), nunca recalculado depois da troca
/// manual pela pílula Oi!|Hi!.
class LanguageState {
  const LanguageState({required this.code, required this.isFirstChoice});

  /// `null` até a criança/pais escolherem pela primeira vez.
  final String? code;
  final bool isFirstChoice;

  LanguageState copyWith({String? code}) => LanguageState(code: code ?? this.code, isFirstChoice: isFirstChoice);
}

class LanguageController extends Notifier<LanguageState> {
  @override
  LanguageState build() {
    final saved = ref.watch(persistenceServiceProvider).languageCode;
    return LanguageState(code: saved, isFirstChoice: saved == null);
  }

  Future<void> choose(String code) async {
    await ref.read(persistenceServiceProvider).setLanguageCode(code);
    state = state.copyWith(code: code);
  }
}

final languageControllerProvider = NotifierProvider<LanguageController, LanguageState>(LanguageController.new);
