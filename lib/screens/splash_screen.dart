import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Animated Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                );
              },
              child: _WalletLogo(color: cs.primary, size: 100),
            ),

            const SizedBox(height: 24),

            // Animated Text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      'Uangku',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola keuanganmu dengan mudah',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Progress indicator
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) {
                return SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressValue.value,
                      backgroundColor: cs.outlineVariant.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      minHeight: 3,
                    ),
                  ),
                );
              },
            ),

            const Spacer(flex: 3),

            // Version text
            FadeTransition(
              opacity: _textOpacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.outline,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletLogo extends StatelessWidget {
  final Color color;
  final double size;
  const _WalletLogo({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WalletPainter(color: color),
      ),
    );
  }
}

class _WalletPainter extends CustomPainter {
  final Color color;
  _WalletPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final walletPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final walletRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.2, w * 0.7, h * 0.65),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(walletRect, fillPaint);
    canvas.drawRRect(walletRect, walletPaint);

    final flapPath = Path()
      ..moveTo(w * 0.18, h * 0.2)
      ..lineTo(w * 0.18, h * 0.12)
      ..quadraticBezierTo(w * 0.18, h * 0.06, w * 0.26, h * 0.06)
      ..lineTo(w * 0.68, h * 0.06)
      ..quadraticBezierTo(w * 0.78, h * 0.06, w * 0.78, h * 0.14)
      ..lineTo(w * 0.78, h * 0.2);
    canvas.drawPath(flapPath, walletPaint);

    canvas.drawLine(
      Offset(w * 0.08, h * 0.48),
      Offset(w * 0.78, h * 0.48),
      walletPaint..strokeWidth = w * 0.025,
    );

    final coinCenter = Offset(w * 0.72, h * 0.55);
    final coinRadius = w * 0.18;
    
    final coinFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final coinBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;

    canvas.drawCircle(coinCenter, coinRadius, coinFill);
    canvas.drawCircle(coinCenter, coinRadius, coinBorder);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        coinCenter.dx - textPainter.width / 2,
        coinCenter.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _WalletPainter old) => old.color != color;
}
