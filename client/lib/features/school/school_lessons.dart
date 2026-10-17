import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../activities/activity_outcome.dart';
import '../activities/count/count_lesson.dart';
import '../activities/letters/letters_lesson.dart';
import '../activities/paint/paint_screen.dart';
import '../activities/rhythm/rhythm_lesson.dart';
import '../activities/shapes/shapes_lesson.dart';
import '../activities/sorting/sorting_lesson.dart';
import 'school_controller.dart';

/// Aula concluída na escola: +3 ⭐ sempre, toda vez (seção 6.5).
class SchoolLessonOutcome extends ActivityOutcome {
  const SchoolLessonOutcome();

  @override
  Future<String?> complete(WidgetRef ref) async {
    await ref.read(schoolControllerProvider.notifier).completeLesson();
    return '+${ref.read(contentRepositoryProvider).school.reward}';
  }
}

/// Anexo B: arte do Ateliê por série.
const _atelierArt = ['flower', 'house', 'garden'];

/// Tela da aula de um espaço, com a dificuldade da série atual (seção 6.8).
Widget lessonScreenFor(SpaceDef space, int grade) {
  const outcome = SchoolLessonOutcome();
  return switch (space.lesson) {
    LessonType.shapes => ShapesLesson(grade: grade, outcome: outcome),
    LessonType.count => CountLesson(grade: grade, outcome: outcome),
    LessonType.paint => PaintScreen(
      outcome: outcome,
      art: _atelierArt[grade.clamp(0, _atelierArt.length - 1)],
    ),
    LessonType.letters => LettersLesson(grade: grade, outcome: outcome),
    LessonType.rhythm => RhythmLesson(grade: grade, outcome: outcome),
    LessonType.sorting => SortingLesson(grade: grade, outcome: outcome),
  };
}
