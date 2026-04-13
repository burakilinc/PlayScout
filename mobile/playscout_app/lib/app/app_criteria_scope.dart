import 'package:flutter/material.dart';

import 'app_criteria_controller.dart';

class AppCriteriaScope extends InheritedNotifier<AppCriteriaController> {
  // [appCriteria] is a runtime [ChangeNotifier]; this cannot be a const constructor.
  // ignore: prefer_const_constructors_in_immutables
  AppCriteriaScope({
    super.key,
    required AppCriteriaController appCriteria,
    required super.child,
  }) : super(notifier: appCriteria);

  static AppCriteriaController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppCriteriaScope>();
    assert(scope != null, 'AppCriteriaScope missing — wrap PlayScoutApp with AppCriteriaScope');
    return scope!.notifier!;
  }
}
