import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class PlacementQuiz extends StatefulWidget {
  const PlacementQuiz({
    super.key,
    required this.onCompleted,
    required this.onSkipped,
  });

  final ValueChanged<String> onCompleted;
  final VoidCallback onSkipped;

  @override
  State<PlacementQuiz> createState() => _PlacementQuizState();
}

class _PlacementQuizState extends State<PlacementQuiz> {
  int _index = 0;
  int _score = 0;
  String? _selected;

  static const _questions = [
    _Question('أي الكلمات اسم؟', ['كتبَ', 'كتابٌ', 'في'], 'كتابٌ'),
    _Question('المبتدأ في «العلمُ نورٌ» هو:', [
      'العلمُ',
      'نورٌ',
      'الجملة كلها',
    ], 'العلمُ'),
    _Question('علامة رفع الفاعل الأصلية:', [
      'الفتحة',
      'الضمة',
      'الكسرة',
    ], 'الضمة'),
    _Question('الفعل المضارع بعد «لن» يكون:', [
      'مرفوعًا',
      'منصوبًا',
      'مجزومًا',
    ], 'منصوبًا'),
    _Question('«إنّ» تنصب:', [
      'الاسم وترفع الخبر',
      'الخبر وترفع الاسم',
      'الاسم والخبر',
    ], 'الاسم وترفع الخبر'),
    _Question('النعت يتبع المنعوت في:', [
      'الإعراب',
      'الزمن فقط',
      'عدد الحروف',
    ], 'الإعراب'),
    _Question('علامة جر المثنى:', ['الكسرة', 'الألف', 'الياء'], 'الياء'),
    _Question('جواب الشرط المجزوم في «إن تجتهد تنجح»:', [
      'إن',
      'تجتهد',
      'تنجح',
    ], 'تنجح'),
    _Question('الجملة بعد الاسم الموصول غالبًا:', [
      'صلة لا محل لها',
      'خبر دائمًا',
      'حال دائمًا',
    ], 'صلة لا محل لها'),
    _Question('«مساجدُ» تُجر غالبًا بـ:', [
      'الكسرة',
      'الفتحة',
      'السكون',
    ], 'الفتحة'),
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
              ),
            ),
            const SizedBox(width: E3rabSpacing.medium),
            Text('${_index + 1}/${_questions.length}'),
          ],
        ),
        const SizedBox(height: E3rabSpacing.xLarge),
        Text(question.prompt, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: E3rabSpacing.medium),
        ...question.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: E3rabSpacing.small),
            child: ChoiceChip(
              selected: _selected == option,
              label: SizedBox(width: double.infinity, child: Text(option)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(E3rabRadii.medium),
              ),
              onSelected: (_) => setState(() => _selected = option),
            ),
          ),
        ),
        const SizedBox(height: E3rabSpacing.medium),
        FilledButton(
          onPressed: _selected == null ? null : _next,
          child: Text(
            _index == _questions.length - 1 ? 'عرض النتيجة' : 'السؤال التالي',
          ),
        ),
        TextButton(
          onPressed: widget.onSkipped,
          child: const Text('تخطي والبدء من الأساس'),
        ),
      ],
    );
  }

  void _next() {
    if (_selected == _questions[_index].answer) _score++;
    if (_index == _questions.length - 1) {
      final level = _score >= 8
          ? 'advanced'
          : _score >= 5
          ? 'intermediate'
          : 'beginner';
      widget.onCompleted(level);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }
}

class _Question {
  const _Question(this.prompt, this.options, this.answer);

  final String prompt;
  final List<String> options;
  final String answer;
}
