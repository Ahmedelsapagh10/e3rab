import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import 'curriculum_track_list.dart';
import 'learning_status_view.dart';

class LearningHubView extends StatefulWidget {
  const LearningHubView({super.key});

  @override
  State<LearningHubView> createState() => _LearningHubViewState();
}

class _LearningHubViewState extends State<LearningHubView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) => LearningStatusView(
        state: state,
        child: ListView(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تعلّم النحو والإعراب',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    const Text(
                      'ابدأ من نوع الكلمة، ثم تعلّم موقعها وعاملها وحالتها وعلامة إعرابها.',
                      style: TextStyle(height: 1.7),
                    ),
                    const SizedBox(height: E3rabSpacing.large),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        labelText: 'ابحث: مفعول به، نعت، مبتدأ وخبر…',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: E3rabSpacing.xLarge),
                    CurriculumTrackList(state: state, query: _query),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
