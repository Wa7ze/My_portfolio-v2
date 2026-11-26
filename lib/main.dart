import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
import 'widgets/custom_cursor.dart';
import 'widgets/idle_watcher.dart';
import 'widgets/terminal_launcher.dart';

@JS('bootDone')
external JSFunction? get _bootDone;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
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
        ChangeNotifierProvider(create: (_) => CursorController()),
        ChangeNotifierProvider(create: (_) => IdleController()),
        ChangeNotifierProvider(create: (_) => TerminalLauncherController()),
      ],
      child: const App(),
    ),
  );

  // Hands off from the HTML boot loader (web/index.html): if a `bootDone`
  // global isn't defined (anything other than the real web build, e.g.
  // `flutter test`), this is a no-op.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _bootDone?.callAsFunction();
  });
}
