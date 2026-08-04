import 'package:flutter_bloc/flutter_bloc.dart';

class ShellCubit extends Cubit<int> {
  ShellCubit() : super(0);

  void selectDestination(int index) {
    if (index != state) emit(index);
  }
}
