import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/vocabulary/presentation/screens/vocabulary_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LingoBreezeApp(),
    ),
  );
}

class LingoBreezeApp extends StatelessWidget {
  const LingoBreezeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoBreeze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const VocabularyScreen(),
    );
  }
}
