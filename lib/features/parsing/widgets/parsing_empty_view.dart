import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class ParsingEmptyView extends StatelessWidget {
  const ParsingEmptyView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const Card(
          child: Padding(
            padding: EdgeInsets.all(E3rabSpacing.xLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fact_check_outlined, size: 64),
                SizedBox(height: E3rabSpacing.medium),
                Text('لا توجد جمل مطابقة حاليًا', textAlign: TextAlign.center),
                SizedBox(height: E3rabSpacing.small),
                Text(
                  'غيّر الباب أو المستوى، أو أعد المحاولة.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
