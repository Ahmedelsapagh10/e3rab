import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../domain/teacher_presentation_builder.dart';

class TeacherPresentationScreen extends StatefulWidget {
  const TeacherPresentationScreen({super.key, required this.slides});

  final List<TeacherSlideModel> slides;

  @override
  State<TeacherPresentationScreen> createState() =>
      _TeacherPresentationScreenState();
}

class _TeacherPresentationScreenState extends State<TeacherPresentationScreen> {
  late final PageController _controller;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _next,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _previous,
        const SingleActivator(LogicalKeyboardKey.space): _next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text('عرض صفي • ${_index + 1}/${widget.slides.length}'),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.slides.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (_, index) => _SlideView(
                    slide: widget.slides[index],
                    position: index + 1,
                    total: widget.slides.length,
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(E3rabSpacing.medium),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _index == 0 ? null : _previous,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('السابق'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _index == widget.slides.length - 1
                            ? null
                            : _next,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('التالي'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_index < widget.slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _previous() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.position,
    required this.total,
  });

  final TeacherSlideModel slide;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'الشريحة $position من $total: ${slide.title}',
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(E3rabSpacing.xLarge),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (slide.example != null) ...[
                const SizedBox(height: E3rabSpacing.xLarge),
                Text(
                  slide.example!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    height: E3rabReadingMetrics.exampleHeight,
                  ),
                ),
              ],
              const SizedBox(height: E3rabSpacing.xLarge),
              ...slide.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: E3rabSpacing.medium),
                  child: Text(
                    '• $line',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(height: 1.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
