import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/teacher_cubit.dart';
import '../screens/teacher_mode_screen.dart';

class TeacherModeEntryCard extends StatelessWidget {
  const TeacherModeEntryCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: ListTile(
      contentPadding: const EdgeInsets.all(E3rabSpacing.medium),
      leading: const Icon(Icons.co_present_outlined, size: 40),
      title: const Text('وضع المعلم'),
      subtitle: const Text(
        'حضّر الدروس، دوّن ملاحظاتك، وأنشئ عرضًا صفيًا وحزم مراجعة.',
      ),
      trailing: const Icon(Icons.arrow_back),
      onTap: () {
        final cubit = context.read<TeacherCubit>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: const TeacherModeScreen(),
            ),
          ),
        );
      },
    ),
  );
}
