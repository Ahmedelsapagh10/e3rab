import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../data/model/teacher_workspace_models.dart';

class TeacherWorkspaceView extends StatelessWidget {
  const TeacherWorkspaceView({
    super.key,
    required this.workspace,
    required this.onCreateCollection,
    required this.onCreateRevisionSet,
    required this.onDeleteCollection,
    required this.onDeleteRevisionSet,
  });

  final TeacherWorkspaceModel workspace;
  final VoidCallback onCreateCollection;
  final VoidCallback onCreateRevisionSet;
  final ValueChanged<String> onDeleteCollection;
  final ValueChanged<String> onDeleteRevisionSet;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(E3rabSpacing.large),
    children: [
      Text('مساحة التحضير', style: Theme.of(context).textTheme.headlineSmall),
      const Text(
        'المجموعات وحزم المراجعة خاصة بك، وتعمل دون إنترنت.',
        style: TextStyle(height: 1.7),
      ),
      const SizedBox(height: E3rabSpacing.medium),
      Wrap(
        spacing: E3rabSpacing.small,
        runSpacing: E3rabSpacing.small,
        children: [
          FilledButton.icon(
            onPressed: onCreateCollection,
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('مجموعة دروس'),
          ),
          OutlinedButton.icon(
            onPressed: onCreateRevisionSet,
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('حزمة مراجعة'),
          ),
        ],
      ),
      const SizedBox(height: E3rabSpacing.large),
      _Heading(title: 'مجموعات الدروس', count: workspace.collections.length),
      if (workspace.collections.isEmpty)
        const Text('لم تُنشئ مجموعة دروس بعد.')
      else
        ...workspace.collections.map(
          (item) => _WorkspaceTile(
            icon: Icons.folder_outlined,
            title: item.title,
            subtitle: '${item.lessonIds.length} دروس',
            onDelete: () => onDeleteCollection(item.id),
          ),
        ),
      const SizedBox(height: E3rabSpacing.large),
      _Heading(title: 'حزم المراجعة', count: workspace.revisionSets.length),
      if (workspace.revisionSets.isEmpty)
        const Text('لم تُنشئ حزمة مراجعة بعد.')
      else
        ...workspace.revisionSets.map(
          (item) => _WorkspaceTile(
            icon: Icons.fact_check_outlined,
            title: item.title,
            subtitle:
                '${item.lessonIds.length} دروس • ${item.exerciseIds.length} تمارين',
            onDelete: () => onDeleteRevisionSet(item.id),
          ),
        ),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) =>
      Text('$title ($count)', style: Theme.of(context).textTheme.titleLarge);
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'حذف $title',
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    ),
  );
}
