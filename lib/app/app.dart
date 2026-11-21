import 'package:flutter/material.dart';

import 'app_environment.dart';

class SnapwatchApp extends StatelessWidget {
  const SnapwatchApp({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: environment.isDev ? 'Snapwatch Dev' : 'Snapwatch',
      debugShowCheckedModeBanner: environment.isDev,
      builder: (context, child) {
        if (!environment.isDev) return child!;
        return Banner(
          message: 'DEV',
          location: BannerLocation.topStart,
          child: child,
        );
      },
      home: const Scaffold(body: Center(child: Text('Snapwatch'))),
    );
  }
}
