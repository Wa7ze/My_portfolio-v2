import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/app_state.dart';
import 'interaction/effects_controller.dart';
import 'interaction/handled_pointers.dart';
import 'interaction/rate_limiter.dart';
import 'interaction/toast_controller.dart';
import 'navigation/nav_controller.dart';
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
        Provider(create: (_) => HandledPointers()),
        Provider(create: (_) => RateLimiter()),
        ChangeNotifierProvider(create: (_) => EffectsController()),
        ChangeNotifierProvider(create: (_) => ToastController()),
        ChangeNotifierProvider(create: (_) => NavController()),
      ],
      child: const App(),
    ),
  );
}
