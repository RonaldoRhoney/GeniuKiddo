import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/guide_avatar.dart';
import '../../app/theme.dart';
import '../../app/top_controls.dart';
import '../../content/content_repository.dart';
import '../../content/labels.dart';
import '../../content/models.dart';
import '../../core/item_feedback.dart';
import '../../core/language_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../activities/free_draw/free_draw_screen.dart';
import '../activities/listen/listen_screen.dart';
import '../activities/match/match_screen.dart';
import '../activities/paint/paint_screen.dart';
import '../activities/speak/speak_screen.dart';
import '../activities/trace/trace_screen.dart';
import 'trail_controller.dart';

const _activityIcons = <ActivityType, IconData>{
  ActivityType.paint: Icons.palette_rounded,
  ActivityType.listen: Icons.hearing_rounded,
  ActivityType.match: Icons.extension_rounded,
  ActivityType.trace: Icons.edit_rounded,
  ActivityType.speak: Icons.record_voice_over_rounded,
};

/// Trilha de atividades (seção 5): mapa de 8 etapas, libera por
/// participação, rabisco livre sempre disponível.
class TrailScreen extends ConsumerStatefulWidget {
  const TrailScreen({super.key});

  @override
  ConsumerState<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends ConsumerState<TrailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final isFirst = ref.read(languageControllerProvider).isFirstChoice;
      ref.read(itemFeedbackProvider).speech.speak(isFirst ? l10n.welcomeFirst : l10n.welcomeBack);
    });
  }

  void _openNode(int index, TrailNodeDef node) {
    final status = ref.read(trailControllerProvider.notifier).statusOf(index);
    if (status == TrailNodeStatus.locked) {
      final l10n = AppLocalizations.of(context)!;
      ref.read(itemFeedbackProvider).speech.speak(l10n.trailLocked);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _activityFor(index, node))).then((_) {
      if (!mounted) return;
      final trail = ref.read(trailControllerProvider);
      final content = ref.read(contentRepositoryProvider);
      final l10n = AppLocalizations.of(context)!;
      final justFinishedThis = trail.done == index + 1;
      if (justFinishedThis) {
        ref.read(itemFeedbackProvider).speech.speak(
              trail.done < content.trail.length ? l10n.trailNewActivity : l10n.trailAllDone,
            );
      } else {
        ref.read(itemFeedbackProvider).speech.speak(l10n.trailPlayMore);
      }
    });
  }

  Widget _activityFor(int index, TrailNodeDef node) {
    return switch (node.type) {
      ActivityType.paint => PaintScreen(nodeIndex: index, art: node.art!),
      ActivityType.trace => TraceScreen(nodeIndex: index, glyph: node.glyph!),
      ActivityType.listen => ListenScreen(nodeIndex: index, items: node.items!),
      ActivityType.match => MatchScreen(nodeIndex: index, items: node.items!),
      ActivityType.speak => SpeakScreen(nodeIndex: index, items: node.items!),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final content = ref.watch(contentRepositoryProvider);
    final trail = ref.watch(trailControllerProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text('${trail.stars}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const TopControls(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const GuideAvatar(size: 56),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        ref.watch(languageControllerProvider).isFirstChoice ? l10n.welcomeFirst : l10n.welcomeBack,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: content.trail.length,
                itemBuilder: (context, index) {
                  final node = content.trail[index];
                  final status = ref.watch(trailControllerProvider.notifier).statusOf(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: index.isOdd ? Alignment.centerRight : (index % 4 == 2 ? Alignment.centerLeft : Alignment.center),
                      child: _TrailNode(
                        title: trailNodeTitle(l10n, node.id),
                        icon: _activityIcons[node.type]!,
                        status: status,
                        onTap: () => _openNode(index, node),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SizedBox(
                height: 60,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: colors.purple, shape: const StadiumBorder()),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FreeDrawScreen())),
                  icon: const Text('🖍️', style: TextStyle(fontSize: 22)),
                  label: Text(l10n.trailFreeDraw, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailNode extends StatelessWidget {
  const _TrailNode({required this.title, required this.icon, required this.status, required this.onTap});

  final String title;
  final IconData icon;
  final TrailNodeStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bg = switch (status) {
      TrailNodeStatus.done => colors.green,
      TrailNodeStatus.current => colors.yellow,
      TrailNodeStatus.locked => const Color(0xFFCFCBE6),
    };
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: status == TrailNodeStatus.locked
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 2.4, sigmaY: 2.4),
                        child: Icon(icon, size: 38, color: Colors.white.withValues(alpha: .7)),
                      )
                    : Icon(icon, size: 38, color: Colors.white),
              ),
              if (status == TrailNodeStatus.done)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.check_rounded, color: colors.green, size: 20),
                  ),
                ),
              if (status == TrailNodeStatus.current)
                const Positioned(right: -24, bottom: -8, child: Text('👆', style: TextStyle(fontSize: 30))),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 120,
            child: Text(
              status == TrailNodeStatus.locked ? '?' : title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink.withValues(alpha: .75)),
            ),
          ),
        ],
      ),
    );
  }
}
