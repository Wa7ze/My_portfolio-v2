import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mazen_portfolio/app.dart';
import 'package:mazen_portfolio/core/app_state.dart';
import 'package:mazen_portfolio/interaction/effects_controller.dart';
import 'package:mazen_portfolio/interaction/handled_pointers.dart';
import 'package:mazen_portfolio/interaction/rate_limiter.dart';
import 'package:mazen_portfolio/interaction/toast_controller.dart';
import 'package:mazen_portfolio/navigation/nav_controller.dart';
import 'package:mazen_portfolio/scene/pak/pak_state.dart';
import 'package:mazen_portfolio/scroll/scroll_progress.dart';

void main() {
  testWidgets('App boots and renders the hero', (WidgetTester tester) async {
    await tester.pumpWidget(
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
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Mazen Matran'), findsOneWidget);
  });
}
