import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/theme/ljl_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardingSlide(
      title: 'Bienvenido a LJL – CoLive',
      body: 'La forma profesional y segura de encontrar vivienda compartida.',
      icon: Icons.verified_user_outlined,
    ),
    _OnboardingSlide(
      title: 'Arrendatario primero',
      body: 'Filtra, guarda favoritos y postúlate con transparencia y control.',
      icon: Icons.favorite_border,
    ),
    _OnboardingSlide(
      title: 'Confianza y soporte',
      body: 'Reportes y bloqueo para una convivencia respetuosa.',
      icon: Icons.shield_outlined,
    ),
  ];

  void _finish() async {
    await context.read<SettingsCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LjlColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(right: 6),
                          height: 8,
                          width: active ? 22 : 8,
                          decoration: BoxDecoration(
                            color: active ? LjlColors.gold : Colors.white24,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Saltar', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                      } else {
                        _finish();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: LjlColors.gold, foregroundColor: LjlColors.dark),
                    child: Text(_index < _pages.length - 1 ? 'Siguiente' : 'Empezar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(icon, color: LjlColors.light, size: 44),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.35, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
