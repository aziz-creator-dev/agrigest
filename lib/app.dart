import 'package:flutter/material.dart';
import 'package:agrigest/screens/home_screen.dart';
import 'package:agrigest/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AgriGestApp extends StatelessWidget {
  const AgriGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriGest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      // 👇 Add these lines for localization support!
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
    );
  }
}
