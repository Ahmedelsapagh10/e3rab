import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../data/model/e3rab_user_profile.dart';

class ProfileFormFields extends StatelessWidget {
  const ProfileFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return Column(
          children: [
            _Dropdown<LearningRole>(
              label: 'دورك في التعلّم',
              value: state.role,
              values: const {
                LearningRole.student: 'طالب',
                LearningRole.teacher: 'معلّم',
                LearningRole.parent: 'ولي أمر',
                LearningRole.independentLearner: 'متعلّم مستقل',
              },
              onChanged: cubit.selectRole,
            ),
            _Dropdown<String>(
              label: 'الدولة والمنهج',
              value: state.countryCode,
              values: const {
                'EG': 'مصر — المنهج الوطني',
                'GLOBAL': 'مسار حر غير مرتبط بدولة',
              },
              onChanged: cubit.selectCountry,
            ),
            _Dropdown<String>(
              label: 'المرحلة',
              value: state.stageId,
              values: const {
                'foundation': 'المسار التأسيسي',
                'primary': 'المرحلة الابتدائية',
                'preparatory': 'المرحلة الإعدادية',
                'secondary': 'المرحلة الثانوية',
                'free': 'المسار الحر',
              },
              onChanged: cubit.selectStage,
            ),
            _Dropdown<String>(
              label: 'الصف أو المسار',
              value: state.gradeId,
              values: const {
                'general': 'عام / تحديد لاحقًا',
                'grade-4': 'الصف الرابع',
                'grade-5': 'الصف الخامس',
                'grade-6': 'الصف السادس',
                'grade-7': 'الصف الأول الإعدادي',
                'grade-8': 'الصف الثاني الإعدادي',
                'grade-9': 'الصف الثالث الإعدادي',
                'grade-10': 'الصف الأول الثانوي',
                'grade-11': 'الصف الثاني الثانوي',
                'grade-12': 'الصف الثالث الثانوي',
              },
              onChanged: cubit.selectGrade,
            ),
            _Dropdown<String>(
              label: 'مستواك الحالي',
              value: state.grammarLevel,
              values: const {
                'beginner': 'مبتدئ',
                'intermediate': 'متوسط',
                'advanced': 'متقدم',
              },
              onChanged: cubit.selectLevel,
            ),
            _Dropdown<String>(
              label: 'هدفك',
              value: state.learningGoal,
              values: const {
                'schoolSuccess': 'التفوق الدراسي',
                'reference': 'مرجع نحوي موثوق',
                'teaching': 'التحضير للتدريس',
                'selfLearning': 'التعلّم الذاتي',
              },
              onChanged: cubit.selectGoal,
            ),
            _Dropdown<int>(
              label: 'الهدف اليومي',
              value: state.dailyGoalMinutes,
              values: const {
                10: '10 دقائق',
                15: '15 دقيقة',
                20: '20 دقيقة',
                30: '30 دقيقة',
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
  });

  final String label;
  final T value;
  final Map<T, String> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
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
}
