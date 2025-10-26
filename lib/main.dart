import 'package:bnultrasoft/theme/theme.dart';
import 'package:bnultrasoft/view/admin/admin_home_screen.dart';  // Your admin screen import
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';  // Import Firebase options


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Quiz",
      theme: AppTheme.theme,  // Correctly apply the theme from AppTheme
      home: AdminHomeScreen(),  // Ensure your admin screen is set as home
    );
  }
}
