import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    required this.selectedIndex,
    required this.onAccountTap,
  });

  final int selectedIndex;
  final VoidCallback onAccountTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.35;
    return AppBar(
      toolbarHeight: 72,
      titleSpacing: E3rabSpacing.large,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BrandMark(),
          const SizedBox(width: E3rabSpacing.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedIndex == 0 ? 'إعراب' : _labels[selectedIndex],
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (!largeText)
                Text(
                  selectedIndex == 0
                      ? 'تعلّم النحو ببساطة'
                      : 'كل خطوة تقرّبك من الإتقان',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            final name = state is AuthAuthenticated
                ? state.profile.displayName
                : null;
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                end: E3rabSpacing.medium,
              ),
              child: Tooltip(
                message: 'فتح حسابي',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAccountTap,
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: E3rabBrandColors.sky,
                    child: Text(
                      _initial(name),
                      style: const TextStyle(
                        color: E3rabBrandColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _initial(String? name) {
    final value = name?.trim() ?? '';
    return value.isEmpty ? 'إ' : value.characters.first;
  }
}

const _labels = ['الرئيسية', 'تعلّم', 'تدرّب', 'حسابي'];

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: E3rabBrandColors.primaryBlue,
      borderRadius: BorderRadius.circular(E3rabRadii.small),
      boxShadow: [
        BoxShadow(
          color: E3rabBrandColors.primaryBlue.withValues(alpha: 0.2),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: const SizedBox.square(
      dimension: 42,
      child: Center(
        child: Text(
          'إ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}
