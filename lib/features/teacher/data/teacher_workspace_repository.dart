import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import 'model/teacher_workspace_models.dart';

abstract class TeacherWorkspaceRepository {
  Future<Either<Failure, TeacherWorkspaceModel>> getWorkspace(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> saveWorkspace(
    LearningDataOwner owner,
    TeacherWorkspaceModel workspace,
  );

  Future<Either<Failure, List<LearningNoteModel>>> getPrivateNotes(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> savePrivateNote(
    LearningDataOwner owner,
    String lessonId,
    String text,
  );
}
