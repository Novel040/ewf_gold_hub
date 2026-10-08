import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const EwfGoldHubApp());
}

class EwfGoldHubApp extends StatelessWidget {
  const EwfGoldHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EWF Gold Hub',
      theme: ThemeData(useMaterial3: true),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      home: const LoginPage(),
    );
  }
}
