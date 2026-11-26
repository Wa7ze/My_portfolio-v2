import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/app_state.dart';
import 'scene/pak/pak_state.dart';
import 'scroll/scroll_progress.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider(create: (_) => SidebarController()),
        ChangeNotifierProvider(create: (_) => ScrollProgress()),
        ChangeNotifierProvider(create: (_) => PakController()),
      ],
      child: const App(),
    ),
  );
}
