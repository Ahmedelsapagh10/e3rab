import 'package:equatable/equatable.dart';

enum PracticeMode { lesson, lessonExam, review, timedTest }

class PracticeSessionConfig extends Equatable {
  const PracticeSessionConfig._({
    required this.mode,
    required this.title,
    required this.allowHint,
    required this.allowReveal,
    required this.showImmediateFeedback,
    this.durationSeconds,
  });

  const PracticeSessionConfig.lesson()
    : this._(
        mode: PracticeMode.lesson,
        title: 'تدريب الدرس',
        allowHint: true,
        allowReveal: true,
        showImmediateFeedback: true,
      );

  const PracticeSessionConfig.lessonExam()
    : this._(
        mode: PracticeMode.lessonExam,
        title: 'اختبار الدرس',
        allowHint: false,
        allowReveal: false,
        showImmediateFeedback: false,
      );

  const PracticeSessionConfig.review()
    : this._(
        mode: PracticeMode.review,
        title: 'مراجعة المهارات',
        allowHint: true,
        allowReveal: true,
        showImmediateFeedback: true,
      );

  const PracticeSessionConfig.timed({int durationSeconds = 300})
    : this._(
        mode: PracticeMode.timedTest,
        title: 'اختبار تراكمي',
        allowHint: false,
        allowReveal: false,
        showImmediateFeedback: false,
        durationSeconds: durationSeconds,
      );

  final PracticeMode mode;
  final String title;
  final bool allowHint;
  final bool allowReveal;
  final bool showImmediateFeedback;
  final int? durationSeconds;

  bool get isTimed => durationSeconds != null;

  @override
  List<Object?> get props => [
    mode,
    title,
    allowHint,
    allowReveal,
    showImmediateFeedback,
    durationSeconds,
  ];
}
