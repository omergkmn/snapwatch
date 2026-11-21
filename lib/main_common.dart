import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_environment.dart';

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SnapwatchApp(environment: environment));
}
