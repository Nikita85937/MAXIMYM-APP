import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'permissions_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _planeController;
  late AnimationController _cloudController;
  late AnimationController _textController;
  late Animation<double> _planeAnimation;
  late Animation<Offset> _cloudAnimation1;
  late Animation<Offset> _cloudAnimation2;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация самолета
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _planeAnimation = CurvedAnimation(
      parent: _planeController,
      curve: Curves.easeInOut,
    );

    // Анимация облаков
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _cloudAnimation1 = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.linear,
    ));

    _cloudAnimation2 = Tween<Offset>(
      begin: const Offset(-2.0, 0),
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.linear,
    ));

    // Анимация текста
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _planeController.forward();
    _cloudController.repeat();

    await Future.delayed(const Duration(milliseconds: 1500));
    _textController.forward();
  }

  @override
  void dispose() {
    _planeController.dispose();
    _cloudController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PermissionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Облака
            Positioned.fill(
              child: Stack(
                children: [
                  SlideTransition(
                    position: _cloudAnimation1,
                    child: const Align(
                      alignment: Alignment(-0.5, -0.3),
                      child: CloudWidget(size: 80),
                    ),
                  ),
                  SlideTransition(
                    position: _cloudAnimation2,
                    child: const Align(
                      alignment: Alignment(0.3, -0.5),
                      child: CloudWidget(size: 60),
                    ),
                  ),
                  SlideTransition(
                    position: _cloudAnimation1,
                    child: const Align(
                      alignment: Alignment(0.7, -0.2),
                      child: CloudWidget(size: 70),
                    ),
                  ),
                ],
              ),
            ),

            // Самолет
            Center(
              child: AnimatedBuilder(
                animation: _planeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -100 * (1 - _planeAnimation.value),
                    ),
                    child: Transform.scale(
                      scale: 0.5 + (_planeAnimation.value * 0.5),
                      child: Opacity(
                        opacity: _planeAnimation.value,
                        child: const Icon(
                          Icons.send,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Текст и кнопка
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Максимум',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Быстрый и безопасный мессенджер',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'НАЧАТЬ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CloudWidget extends StatelessWidget {
  final double size;

  const CloudWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: CustomPaint(
        size: Size(size, size * 0.6),
        painter: CloudPainter(),
      ),
    );
  }
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Рисуем облако из кругов
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.5),
      size.width * 0.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      size.width * 0.25,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.5),
      size.width * 0.2,
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.5,
        size.width * 0.6,
        size.height * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
