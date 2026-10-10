import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const spenvaPurple = Color(0xff555d91);
const spenvaBackground = Color(0xfff9f7fd);
const spenvaBlue = Color(0xff21a5de);

/// Shared by runtime screens and store capture; appearance is unchanged.
ThemeData spenvaTheme() => ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: spenvaPurple),
          useMaterial3: true,
          fontFamily: 'SpenvaSans',
          scaffoldBackgroundColor: spenvaBackground,
          appBarTheme: const AppBarTheme(backgroundColor: spenvaBackground, surfaceTintColor: Colors.transparent),
          cardTheme: CardThemeData(color: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
            backgroundColor: spenvaPurple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
        );

class SpenvaLogo extends StatelessWidget {
  const SpenvaLogo({super.key, this.signIn = false, this.markOnly = false});
  final bool signIn, markOnly;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/${markOnly ? "mark" : signIn ? "sign_in" : "header"}.png',
    fit: BoxFit.contain, semanticLabel: 'Spenva',
  );
}

String greetingFor(DateTime localTime, String? displayName) {
  final hour = localTime.hour;
  final greeting = hour < 4 || hour >= 18 ? 'Selamat malam' : hour < 11 ? 'Selamat pagi' : hour < 15 ? 'Selamat siang' : 'Selamat sore';
  final name = displayName?.trim().split(RegExp(r'\s+')).first ?? '';
  return name.isEmpty ? greeting : '$greeting, $name';
}

class SpenvaGreeting extends StatefulWidget {
  const SpenvaGreeting({super.key, this.displayName});
  final String? displayName;
  @override
  State<SpenvaGreeting> createState() => _SpenvaGreetingState();
}

class _SpenvaGreetingState extends State<SpenvaGreeting> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  Timer? _clock;
  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _clock = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context)) _animation.forward();
  }
  @override
  void dispose() { _clock?.cancel(); _animation.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(greetingFor(DateTime.now(), widget.displayName), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (MediaQuery.textScalerOf(context).scale(12) <= 15)
          const Text('Yuk, catat cerita keuangan hari ini.', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Color(0xff76768b))),
      ])),
      const SizedBox(width: 10),
      AnimatedBuilder(animation: _animation, builder: (_, child) => Transform.rotate(
        angle: math.sin(_animation.value * math.pi * 4) * .15, child: child,
      ), child: const CircleAvatar(backgroundColor: Color(0xffeeeaf8), child: Icon(Icons.waving_hand_outlined, color: spenvaPurple))),
    ]),
  );
}

class SpenvaDecoration extends StatelessWidget {
  const SpenvaDecoration({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [spenvaBackground, Color(0xfff0edfc), spenvaBackground])),
    child: Stack(children: [
      Positioned(top: -100, left: -100, child: _orb(220)),
      Positioned(top: 130, right: -125, child: _orb(230)),
      Positioned.fill(child: child),
    ]),
  );
  Widget _orb(double size) => ExcludeSemantics(child: Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: spenvaPurple.withValues(alpha: .045))));
}
