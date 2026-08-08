import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/parsing_cubit.dart';
import '../cubit/parsing_state.dart';
import 'parsing_empty_view.dart';
import 'parsing_filters_bar.dart';
import 'parsing_report_dialog.dart';
import 'parsing_result_view.dart';
import 'parsing_step_view.dart';

class ParsingLabView extends StatelessWidget {
  const ParsingLabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParsingCubit, ParsingState>(
      listenWhen: (previous, current) =>
          !previous.reportSaved && current.reportSaved,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حُفظ البلاغ بصورة خاصة للمراجعة.')),
      ),
      builder: (context, state) => switch (state.status) {
        ParsingLabStatus.initial || ParsingLabStatus.loading => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'تحميل معمل الإعراب',
          ),
        ),
        ParsingLabStatus.empty => const ParsingEmptyView(),
        ParsingLabStatus.failure => _FailureView(
          message: state.message ?? 'تعذّر فتح معمل الإعراب.',
          onRetry: context.read<ParsingCubit>().load,
        ),
        ParsingLabStatus.ready => Column(
          children: [
            if (state.previewMode) const _DraftPreviewBanner(),
            ParsingFiltersBar(
              state: state,
              onTrackChanged: context.read<ParsingCubit>().selectTrack,
              onDifficultyChanged: context
                  .read<ParsingCubit>()
                  .selectDifficulty,
            ),
            _ParsingToolbar(state: state),
            Expanded(
              child: state.completed
                  ? ParsingResultView(
                      state: state,
                      onNextSample: context.read<ParsingCubit>().nextSample,
                    )
                  : ParsingStepView(
                      state: state,
                      onSelect: context.read<ParsingCubit>().selectOption,
                      onSubmit: context.read<ParsingCubit>().submit,
                      onNext: context.read<ParsingCubit>().nextStep,
                    ),
            ),
          ],
        ),
      },
    );
  }
}

class _ParsingToolbar extends StatelessWidget {
  const _ParsingToolbar({required this.state});

  final ParsingState state;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      E3rabSpacing.medium,
      E3rabSpacing.small,
      E3rabSpacing.medium,
      0,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            state.currentSample.sentence,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: state.saved ? 'إزالة من المحفوظات' : 'حفظ المثال',
          onPressed: context.read<ParsingCubit>().toggleSaved,
          icon: Icon(state.saved ? Icons.bookmark : Icons.bookmark_border),
        ),
        IconButton(
          tooltip: 'الإبلاغ عن خطأ',
          onPressed: () => _report(context),
          icon: const Icon(Icons.flag_outlined),
        ),
      ],
    ),
  );

  Future<void> _report(BuildContext context) async {
    final text = await showParsingReportDialog(context);
    if (text != null && context.mounted) {
      await context.read<ParsingCubit>().reportError(text);
    }
  }
}

class _DraftPreviewBanner extends StatelessWidget {
  const _DraftPreviewBanner();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.tertiaryContainer,
    padding: const EdgeInsets.all(E3rabSpacing.small),
    child: const Text(
      'معاينة تطوير فقط: هذا التحليل غير معتمد ولا يظهر للطلاب.',
      textAlign: TextAlign.center,
    ),
  );
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: E3rabSpacing.medium),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}
