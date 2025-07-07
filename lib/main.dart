import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/form_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/score_card_form_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FormProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CTS Inspector',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: ScoreCardFormScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}