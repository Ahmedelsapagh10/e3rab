import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/model/lesson_model.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/screens/lesson_screen.dart';

abstract final class ReferenceLessonNavigator {
  static Future<void> open(
    BuildContext context, {
    required LearningCubit learningCubit,
    required LessonModel lesson,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: learningCubit,
          child: LessonScreen(lesson: lesson),
        ),
      ),
    );
  }
}
