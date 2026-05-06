import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: Replace with Rive thread animation
              const _ThreadPlaceholder(),

              const SizedBox(height: AppSpacing.xl),

              Text(
                l10n.giftOnItsWay,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Temp: go to inbox to see the flow
              TextButton(
                onPressed: () => context.goNamed(RouteNames.inbox),
                child: Text(
                  l10n.inbox,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.iris,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadPlaceholder extends StatefulWidget {
  const _ThreadPlaceholder();

  @override
  State<_ThreadPlaceholder> createState() => _ThreadPlaceholderState();
}

class _ThreadPlaceholderState extends State<_ThreadPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(200, 100),
          painter: _SimpleThreadPainter(_controller.value),
        );
      },
    );
  }
}

class _SimpleThreadPainter extends CustomPainter {
  final double progress;
  _SimpleThreadPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.8,
        size.width,
        size.height / 2,
      );

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = AppColors.iris
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SimpleThreadPainter old) => old.progress != progress;
}
