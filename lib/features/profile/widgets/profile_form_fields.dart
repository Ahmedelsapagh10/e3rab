import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileFormFields extends StatelessWidget {
  const ProfileFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return Column(
          children: [
            _Dropdown<String>(
              label: 'مستواك الآن',
              helper: 'اختيار اختياري؛ مسار التعلّم يبدأ بالأساس للجميع.',
              value: state.grammarLevel,
              values: const {
                'beginner': 'أبدأ من الأساس',
                'intermediate': 'أعرف القواعد الأساسية',
                'advanced': 'أريد التعمق والتطبيق',
              },
              onChanged: cubit.selectLevel,
            ),
            _Dropdown<String>(
              label: 'هدفك من التعلّم',
              value: state.learningGoal,
              values: const {
                'schoolSuccess': 'أفهم النحو للدراسة',
                'reference': 'أحتاج مرجعًا واضحًا',
                'teaching': 'أقوّي شرحي للآخرين',
                'selfLearning': 'أتعلم لنفسي',
              },
              onChanged: cubit.selectGoal,
            ),
            _Dropdown<int>(
              label: 'كم دقيقة تناسبك يوميًا؟',
              value: state.dailyGoalMinutes,
              values: const {
                10: '10 دقائق — بداية خفيفة',
                15: '15 دقيقة — اختيار متوازن',
                20: '20 دقيقة — تقدم أسرع',
                30: '30 دقيقة — تعلم مكثف',
              },
              onChanged: cubit.selectDailyGoal,
            ),
          ],
        );
      },
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.helper,
  });

  final String label;
  final String? helper;
  final T value;
  final Map<T, String> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, helperText: helper),
      items: values.entries
          .map(
            (entry) => DropdownMenuItem<T>(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    ),
  );
}
