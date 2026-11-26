import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'router.dart';
import 'widgets/opening_splash.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();

    return MaterialApp.router(
      title: 'Mazen Matran — Portfolio',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: localeController.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Text selectability (SelectionArea) is applied per-route instead,
      // inside the Router — see router.dart for why.
      builder: (context, child) => OpeningSplash(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
