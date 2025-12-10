import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'themes/app_theme.dart';
import 'screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EditorApp());
}

class EditorApp extends StatelessWidget {
  const EditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => FileExplorerProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'EditorOne',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isLoading ? ThemeMode.system : settings.themeMode,
            home: const EditorScreen(),
          );
        },
      ),
    );
  }
}
