import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sync_cubit.dart';
import '../cubit/sync_state.dart';
import '../../learning/cubit/learning_cubit.dart';

class GuestMergeListener extends StatelessWidget {
  const GuestMergeListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncCubit, GuestMergeState>(
      listener: (context, state) {
        if (state.status == GuestMergeStatus.offer) _showOffer(context);
        if (state.status == GuestMergeStatus.completed ||
            state.status == GuestMergeStatus.failed) {
          if (state.status == GuestMergeStatus.completed) {
            context.read<LearningCubit>().load();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'اكتملت المزامنة.')),
          );
        }
        if (state.status == GuestMergeStatus.none ||
            state.status == GuestMergeStatus.skipped) {
          context.read<LearningCubit>().load();
        }
      },
      child: child,
    );
  }

  Future<void> _showOffer(BuildContext context) async {
    final cubit = context.read<SyncCubit>();
    final merge = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('دمج تقدم الضيف؟'),
        content: const Text(
          'وجدنا تقدمًا محفوظًا على هذا الجهاز. سنضيفه إلى حسابك دون استبدال تقدم الحساب أو حذف بيانات الضيف قبل اكتمال الدمج.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ليس الآن'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('دمج'),
          ),
        ],
      ),
    );
    if (merge == true) {
      await cubit.merge();
    } else {
      cubit.skip();
    }
  }
}
