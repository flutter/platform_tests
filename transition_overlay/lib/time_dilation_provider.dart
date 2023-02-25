import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class TimeDilationProvider extends InheritedWidget {
  TimeDilationProvider({super.key, required super.child});

  final timeDilationNotifier = ValueNotifier<double>(1.0);

  void setNewTimeDilation(double newTimeDilation) {
    timeDilationNotifier.value = newTimeDilation;

    timeDilation = newTimeDilation;
  }

  static TimeDilationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TimeDilationProvider>();
  }

  @override
  bool updateShouldNotify(TimeDilationProvider oldWidget) {
    return oldWidget != this;
  }
}
