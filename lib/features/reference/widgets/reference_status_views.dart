import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class ReferenceEmptyResults extends StatelessWidget {
  const ReferenceEmptyResults({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(E3rabSpacing.large),
      child: Text(
        'لا توجد نتيجة مطابقة. جرّب كلمة أقصر أو اكتبها بلا تشكيل.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class ReferenceFailureView extends StatelessWidget {
  const ReferenceFailureView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    ),
  );
}
