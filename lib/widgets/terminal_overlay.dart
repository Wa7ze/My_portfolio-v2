import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/strings/app_strings.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/portfolio_content.dart';
import '../navigation/nav_controller.dart';
import '../navigation/section_registry.dart';

/// The hidden terminal (PRD section 13) — loaded as a deferred library
/// (see `terminal_launcher.dart`) so its cost is paid only on first open.
/// Supports every command in the PRD's table; Up/Down history-cycling and
/// Tab-autocomplete are UX sugar beyond that table and are not built here.
class TerminalOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const TerminalOverlay({super.key, required this.onClose});

  @override
  State<TerminalOverlay> createState() => _TerminalOverlayState();
}

class _TerminalOverlayState extends State<TerminalOverlay> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _outputScroll = ScrollController();
  final List<String> _output = ['type help to list commands'];
  final List<String> _history = [];

  static const _sectionsByName = {
    'home': SectionId.browserHero,
    'about': SectionId.networkAbout,
    'skills': SectionId.gatewaySkills,
    'projects': SectionId.apiProjects,
    'approach': SectionId.logicApproach,
    'experience': SectionId.databaseExperience,
    'contact': SectionId.responseContact,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inputFocus.requestFocus());
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _outputScroll.dispose();
    super.dispose();
  }

  void _print(String line) {
    setState(() => _output.add(line));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_outputScroll.hasClients) _outputScroll.jumpTo(_outputScroll.position.maxScrollExtent);
    });
  }

  void _routeTo(SectionId target) {
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onClose();
      if (context.mounted) context.read<NavController>().goTo(context, target);
    });
  }

  void _run(String raw) {
    final cmd = raw.trim();
    _input.clear();
    if (cmd.isEmpty) return;
    _history.add(cmd);
    _print('guest@portfolio:~\$ $cmd');
    _execute(cmd);
  }

  void _execute(String cmd) {
    final parts = cmd.split(RegExp(r'\s+'));
    final head = parts.first.toLowerCase();
    final rest = parts.skip(1).join(' ');
    final strings = context.strings;

    switch (head) {
      case 'help':
        _print('help, whoami, ls, ls projects, cat <slug>, cd <section>, curl /<section>,');
        _print('open github|linkedin|cv, history, clear, sudo hire <anything>, exit');
      case 'whoami':
        _print(strings.summaryBody);
      case 'ls':
        if (rest == 'projects') {
          for (final p in PortfolioContent.projects) {
            _print('${p.slug}  (${p.tags.join(", ")})');
          }
        } else {
          _print(_sectionsByName.keys.join('  '));
        }
      case 'cat':
        Project? project;
        for (final p in PortfolioContent.projects) {
          if (p.slug == rest) project = p;
        }
        if (project == null) {
          _print('cat: $rest: no such project');
        } else {
          _print('${project.title} — ${project.summary}');
          _print('repo: ${project.githubUrl}');
        }
      case 'cd':
      case 'curl':
        final name = rest.replaceFirst('/', '');
        final target = _sectionsByName[name];
        if (target == null) {
          _print('$head: $name: no route to host');
        } else {
          _print('→ routing to /$name');
          _routeTo(target);
        }
      case 'open':
        switch (rest) {
          case 'github':
            _print('→ opening github');
          case 'linkedin':
            _print('→ opening linkedin');
          case 'cv':
            _print('→ opening cv');
          default:
            _print('open: $rest: unknown target');
        }
      case 'history':
        for (var i = 0; i < _history.length; i++) {
          _print('${i + 1}  ${_history[i]}');
        }
      case 'clear':
        setState(_output.clear);
      case 'sudo':
        if (rest.startsWith('hire')) {
          _print('[sudo] permission granted.');
          _print('→ opening /contact');
          _routeTo(SectionId.responseContact);
        } else {
          _print('sudo: $rest: command not found');
        }
      case 'exit':
        widget.onClose();
      default:
        _print('command not found: $cmd. try help');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final size = MediaQuery.sizeOf(context);
    final isMobile = AppBreakpoints.isMobile(size.width);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: size.height * (isMobile ? 0.9 : 0.45),
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onClose();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          color: palette.bgRaised,
          child: Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.netCyan))),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _outputScroll,
                    itemCount: _output.length,
                    itemBuilder: (context, i) => Text(
                      _output[i],
                      textDirection: TextDirection.ltr,
                      style: AppType.mono.copyWith(color: palette.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Text('guest@portfolio:~\$ ', textDirection: TextDirection.ltr, style: AppType.mono.copyWith(color: AppColors.netCyan)),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        focusNode: _inputFocus,
                        autofocus: true,
                        textDirection: TextDirection.ltr,
                        style: AppType.mono.copyWith(color: palette.textPrimary),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onSubmitted: _run,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
