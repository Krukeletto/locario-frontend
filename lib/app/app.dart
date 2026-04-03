import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class LocarioApp extends StatelessWidget {
  const LocarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Locario',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
