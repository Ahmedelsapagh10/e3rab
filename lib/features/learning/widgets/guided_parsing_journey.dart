import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class GuidedParsingJourney extends StatefulWidget {
  const GuidedParsingJourney({
    super.key,
    required this.example,
    required this.onCompleted,
  });

  final GrammarExampleModel example;
  final Future<void> Function() onCompleted;

  @override
  State<GuidedParsingJourney> createState() => _GuidedParsingJourneyState();
}

class _GuidedParsingJourneyState extends State<GuidedParsingJourney> {
  late final List<_ParsingDecision> _decisions = _buildDecisions();
  var _index = 0;
  var _revealed = false;

  bool get _finished => _index == _decisions.length - 1 && _revealed;

  @override
  Widget build(BuildContext context) {
    final decision = _decisions[_index];
    return ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: E3rabReadingMetrics.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.example.fullyDiacritizedSentence,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: E3rabSpacing.medium),
                Text(
                  'نبني الإعراب قرارًا بعد قرار. فكّر أولًا، ثم اكشف الإجابة.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: E3rabSpacing.large),
                LinearProgressIndicator(
                  value: (_index + (_revealed ? 1 : 0)) / _decisions.length,
                  semanticsLabel: 'تقدم الإعراب الموجّه',
                ),
                const SizedBox(height: E3rabSpacing.large),
                _DecisionCard(decision: decision, revealed: _revealed),
                const SizedBox(height: E3rabSpacing.large),
                FilledButton.icon(
                  onPressed: _finished ? widget.onCompleted : _advance,
                  icon: Icon(
                    _finished
                        ? Icons.check_rounded
                        : _revealed
                        ? Icons.arrow_back_rounded
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    _finished
                        ? 'أكملت الإعراب الموجّه'
                        : _revealed
                        ? 'القرار التالي'
                        : 'اكشف الإجابة',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _advance() {
    setState(() {
      if (_revealed) {
        _index++;
        _revealed = false;
      } else {
        _revealed = true;
      }
    });
  }

  List<_ParsingDecision> _buildDecisions() => [
    for (final word in widget.example.parsedWords) ...[
      _ParsingDecision(word.word, 'ما نوع هذه الكلمة؟', word.wordType),
      _ParsingDecision(
        word.word,
        'ما موقعها أو وظيفتها؟',
        word.grammaticalRole,
      ),
      _ParsingDecision(
        word.word,
        'ما العامل المؤثر فيها؟',
        word.grammaticalAgent.isEmpty
            ? 'عامل معنوي أو غير مذكور'
            : word.grammaticalAgent,
      ),
      _ParsingDecision(
        word.word,
        'ما حالتها الإعرابية؟',
        word.grammaticalState,
      ),
      _ParsingDecision(word.word, 'ما علامة الإعراب؟', word.grammaticalSign),
      _ParsingDecision(word.word, 'لماذا جاءت هذه العلامة؟', word.signReason),
      _ParsingDecision(
        word.word,
        'هل للجملة محل من الإعراب؟',
        word.sentencePosition.isEmpty
            ? 'لا ينطبق على هذه الكلمة'
            : word.sentencePosition,
        explanation: word.explanation,
      ),
    ],
  ];
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision, required this.revealed});

  final _ParsingDecision decision;
  final bool revealed;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(decision.word, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: E3rabSpacing.small),
          Text(
            decision.question,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: E3rabSpacing.medium),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: revealed
                ? Semantics(
                    key: const ValueKey('answer'),
                    liveRegion: true,
                    child: Text(
                      '${decision.answer}${decision.explanation == null ? '' : '\n${decision.explanation}'}',
                      style: const TextStyle(height: 1.7),
                    ),
                  )
                : const Text(
                    'قل إجابتك أو فكّر فيها قبل الكشف.',
                    key: ValueKey('prompt'),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _ParsingDecision {
  const _ParsingDecision(
    this.word,
    this.question,
    this.answer, {
    this.explanation,
  });

  final String word;
  final String question;
  final String answer;
  final String? explanation;
}
