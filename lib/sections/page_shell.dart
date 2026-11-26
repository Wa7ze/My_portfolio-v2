import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../interaction/click_router.dart';
import '../interaction/effects_layer.dart';
import '../navigation/hash_sync.dart';
import '../navigation/nav_bar.dart';
import '../navigation/section_registry.dart';
import '../scene/background_layer.dart';
import '../scene/pak/pak_state.dart';
import '../scene/pak/pak_widget.dart';
import '../scene/path_painter.dart';
import '../scroll/eof_scroll_physics.dart';
import '../scroll/scroll_progress.dart';
import '../widgets/latency_counter.dart';
import '../widgets/skip_link.dart';
import 's0_browser_hero.dart';
import 's1_network_about.dart';
import 's2_gateway_skills.dart';
import 's3_api_projects.dart';
import 's4_logic_approach.dart';
import 's5_database_experience.dart';
import 's6_response_contact.dart';
import 's7_teardown_footer.dart';

/// The single scrollable page holding all 8 sections in fixed order, owning
/// the one ScrollController that every scroll-driven visual reads from (via
/// [ScrollProgress], attached/detached here). Re-measures [SectionRegistry]
/// offsets after every layout pass so they stay correct across viewport
/// size changes, and syncs the URL hash with the active section.
class PageShell extends StatefulWidget {
  const PageShell({super.key});

  @override
  State<PageShell> createState() => _PageShellState();
}

class _PageShellState extends State<PageShell> with WidgetsBindingObserver {
  final ScrollController controller = ScrollController();
  final FocusNode _contentFocus = FocusNode(debugLabel: 'page content (skip link target)');
  ScrollProgress? _scrollProgress;
  SkipLinkController? _skipLink;
  bool _initialHashHandled = false;
  SectionId? _lastHashSection;

  // End-of-page teardown trigger (PRD section 12): fires once per arrival
  // within 40px of the bottom, re-arms once scrolled back up past 400px
  // from the bottom.
  bool _endArmed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _remeasure());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollProgress = context.read<ScrollProgress>();
    if (!identical(_scrollProgress, scrollProgress)) {
      _scrollProgress?.removeListener(_onScrollProgressChanged);
      _scrollProgress?.detach(controller);
      scrollProgress.attach(controller);
      scrollProgress.addListener(_onScrollProgressChanged);
      _scrollProgress = scrollProgress;
    }
    final skipLink = context.read<SkipLinkController>();
    if (!identical(_skipLink, skipLink)) {
      _skipLink?.detach(_contentFocus);
      skipLink.attach(_contentFocus);
      _skipLink = skipLink;
    }
  }

  // Viewport size changes (resize, orientation) can shift every section's
  // offset, so re-measure then — not on every build, which would otherwise
  // pile up a postFrameCallback per rebuild for no reason.
  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _remeasure());
  }

  void _remeasure() {
    if (!mounted) return;
    SectionRegistry.measure(context, controller);

    if (!_initialHashHandled) {
      _initialHashHandled = true;
      final target = HashSync.readInitialSection();
      if (target != null && controller.hasClients) {
        controller.jumpTo(SectionRegistry.offsetFor(target).clamp(0.0, controller.position.maxScrollExtent));
      }
    }

    _scrollProgress?.refresh();
  }

  void _onScrollProgressChanged() {
    final active = _scrollProgress?.activeSection;
    if (active != null && active != _lastHashSection) {
      _lastHashSection = active;
      HashSync.onScrollActiveSectionChanged(active);
    }
    _checkEndTrigger();
  }

  void _checkEndTrigger() {
    if (!controller.hasClients) return;
    final position = controller.position;
    final distanceFromEnd = position.maxScrollExtent - position.pixels;
    final scrollProgress = _scrollProgress;
    if (scrollProgress == null) return;

    if (_endArmed && distanceFromEnd <= 40) {
      _endArmed = false;
      scrollProgress.setEnded(true);
      context.read<PakController>().react(PakMood.bowing, duration: const Duration(milliseconds: 900));
    } else if (!_endArmed && distanceFromEnd >= 400) {
      _endArmed = true;
      scrollProgress.setEnded(false);
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!controller.hasClients) return;
    final position = controller.position;
    if (position.pixels < position.maxScrollExtent - 0.5) return;
    if (event.scrollDelta.dy <= 0) return;
    _scrollProgress?.addPull(event.scrollDelta.dy / 600);
  }

  bool _onOverscroll(OverscrollNotification notification) {
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 0.5 && notification.overscroll > 0) {
      _scrollProgress?.addPull(notification.overscroll / 120);
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollProgress?.removeListener(_onScrollProgressChanged);
    _scrollProgress?.detach(controller);
    _skipLink?.detach(_contentFocus);
    _contentFocus.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: ExcludeSemantics(child: BackgroundLayer())),
          Listener(
            onPointerSignal: _onPointerSignal,
            child: NotificationListener<OverscrollNotification>(
              onNotification: _onOverscroll,
              child: SingleChildScrollView(
                controller: controller,
                physics: const EofScrollPhysics(),
                child: Focus(
                  focusNode: _contentFocus,
                  skipTraversal: true,
                  descendantsAreFocusable: true,
                  child: ClickRouter(
                  child: Stack(
                    children: const [
                      Column(
                        children: [
                          SizedBox(height: NavBar.height),
                          BrowserHeroSection(),
                          NetworkAboutSection(),
                          GatewaySkillsSection(),
                          ApiProjectsSection(),
                          LogicApproachSection(),
                          DatabaseExperienceSection(),
                          ResponseContactSection(),
                          TeardownFooterSection(),
                        ],
                      ),
                      Positioned.fill(child: ExcludeSemantics(child: IgnorePointer(child: PathLayer()))),
                      Positioned.fill(child: ExcludeSemantics(child: IgnorePointer(child: PakWidget()))),
                      Positioned.fill(child: ExcludeSemantics(child: EffectsLayer())),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ),
          const LatencyCounter(),
          const ToastHost(),
        ],
      ),
    );
  }
}
