import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/celebration/celebration_overlay.dart';
import 'persistence_service.dart';

/// Relógio de parede usado pra medir quanto tempo o app ficou em segundo
/// plano — sobrescrito nos testes.
final breakClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Tempo fora do app que já conta como descanso: ao voltar depois disso, a
/// contagem da pausa recomeça do zero.
const breakRestThreshold = Duration(minutes: 10);

/// Seção 4.8 — pausa sugerida: depois de `breakMinutes` de uso contínuo
/// (0 = desligada), `state` vira `true` e a UI mostra a sobreposição.
/// "Uso contínuo" = tempo com o app em primeiro plano: tocar na tela NÃO
/// reinicia a contagem (senão a pausa nunca viria enquanto a criança
/// brinca). A contagem só zera quando os pais fecham a pausa pelo portão,
/// quando a duração muda, ou quando a criança fica fora do app por
/// `breakRestThreshold` ou mais.
class BreakController extends Notifier<bool> {
  Timer? _timer;

  /// Uso acumulado em primeiro plano antes do trecho atual.
  Duration _used = Duration.zero;

  /// Início do trecho atual em primeiro plano (`null` = em segundo plano).
  DateTime? _foregroundSince;

  /// Quando o app foi pra segundo plano (`null` = em primeiro plano).
  DateTime? _backgroundSince;

  DateTime _now() => ref.read(breakClockProvider)();

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    _used = Duration.zero;
    _foregroundSince = _now();
    _schedule();
    return false;
  }

  Duration get _limit =>
      Duration(minutes: ref.read(persistenceServiceProvider).breakMinutes);

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    if (_limit <= Duration.zero || _foregroundSince == null) return;
    final remaining = _limit - _used;
    _timer = Timer(remaining.isNegative ? Duration.zero : remaining, _fire);
  }

  void _fire() {
    // "Se uma celebração estiver aberta, adiar a pausa" — tenta de novo em
    // 10s em vez de interromper a comemoração da criança.
    if (ref.read(celebrationOpenProvider)) {
      _timer = Timer(const Duration(seconds: 10), _fire);
      return;
    }
    state = true;
  }

  /// App foi pra segundo plano: congela a contagem.
  void onBackground() {
    final since = _foregroundSince;
    if (since == null) return;
    final now = _now();
    _used += now.difference(since);
    _foregroundSince = null;
    _backgroundSince = now;
    _timer?.cancel();
    _timer = null;
  }

  /// App voltou pro primeiro plano: retoma a contagem de onde parou, ou
  /// recomeça do zero se o tempo fora já valeu como descanso.
  void onForeground() {
    if (_foregroundSince != null) return;
    final now = _now();
    final away = _backgroundSince;
    if (away != null && now.difference(away) >= breakRestThreshold) {
      _used = Duration.zero;
    }
    _backgroundSince = null;
    _foregroundSince = now;
    if (!state) _schedule();
  }

  /// Recomeça a contagem do zero — usado quando os pais mudam a duração.
  void restart() {
    if (state) return; // sobreposição aberta — só o portão fecha
    _used = Duration.zero;
    _foregroundSince = _now();
    _schedule();
  }

  /// Chamado pelo portão (`HoldToUnlock`) dentro da sobreposição.
  void dismiss() {
    state = false;
    restart();
  }
}

final breakControllerProvider = NotifierProvider<BreakController, bool>(
  BreakController.new,
);
