import 'package:flutter/widgets.dart';

/// Duração de uma animação respeitando "reduzir movimento" (4.10): com a
/// opção ligada no aparelho, a mudança acontece na hora, sem animar.
Duration motion(BuildContext context, Duration normal) =>
    MediaQuery.of(context).disableAnimations ? Duration.zero : normal;
