import 'package:equatable/equatable.dart';

enum PracticeMode { lesson, review, timedTest }

class PracticeSessionConfig extends Equatable {
  const PracticeSessionConfig._({
    required this.mode,
    required this.title,
    required this.allowReveal,
    this.durationSeconds,
  });

  const PracticeSessionConfig.lesson()
    : this._(
        mode: PracticeMode.lesson,
        title: 'تدريب الدرس',
        allowReveal: true,
      );

  const PracticeSessionConfig.review()
    : this._(
        mode: PracticeMode.review,
        title: 'مراجعة المهارات',
        allowReveal: true,
      );

  const PracticeSessionConfig.timed({int durationSeconds = 300})
    : this._(
        mode: PracticeMode.timedTest,
        title: 'اختبار تراكمي',
        allowReveal: false,
        durationSeconds: durationSeconds,
      );

  final PracticeMode mode;
  final String title;
  final bool allowReveal;
  final int? durationSeconds;

  bool get isTimed => durationSeconds != null;

  @override
  List<Object?> get props => [mode, title, allowReveal, durationSeconds];
}
