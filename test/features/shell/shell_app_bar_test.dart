import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/auth/cubit/auth_cubit.dart';
import 'package:new_strucuture/features/shell/widgets/shell_app_bar.dart';

import '../auth/auth_test_fakes.dart';

void main() {
  testWidgets('branded app bar supports compact large text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final authRepository = FakeAuthRepository();
    final cubit = AuthCubit(authRepository, FakeUserProfileRepository());
    addTearDown(cubit.close);
    addTearDown(authRepository.close);
    var openedAccount = false;

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          ),
          home: Scaffold(
            appBar: ShellAppBar(
              selectedIndex: 0,
              onAccountTap: () => openedAccount = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('إعراب'), findsOneWidget);
    await tester.tap(find.byTooltip('فتح حسابي'));
    expect(openedAccount, isTrue);
    expect(tester.takeException(), isNull);
  });
}
