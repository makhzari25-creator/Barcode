import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';

/// قاب دوربین بارکدخوان با گوشه‌های فیروزه‌ای و خط اسکن متحرک
class ScannerPanel extends StatefulWidget {
  final MobileScannerController? controller;
  final bool ready;
  final bool paused;
  final void Function(BarcodeCapture capture) onDetect;
  final VoidCallback onResume;
  final double height;

  const ScannerPanel({
    super.key,
    required this.controller,
    required this.ready,
    required this.paused,
    required this.onDetect,
    required this.onResume,
    this.height = 260,
  });

  @override
  State<ScannerPanel> createState() => _ScannerPanelState();
}

class _ScannerPanelState extends State<ScannerPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.ready && controller != null)
              MobileScanner(
                controller: controller,
                onDetect: widget.onDetect,
                errorBuilder: (context, error, child) => const _CameraError(),
              )
            else
              Container(
                color: const Color(0xFF0B1A1F),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.cyan),
                ),
              ),
            IgnorePointer(
              child: CustomPaint(
                painter: _FramePainter(
                  progress: _line,
                  showLine: !widget.paused,
                ),
              ),
            ),
            if (!widget.paused)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.center_focus_strong_rounded,
                            color: AppColors.cyan, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'بارکد کالا را داخل کادر قرار دهید',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.paused)
              Positioned.fill(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: InkWell(
                    onTap: widget.onResume,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill_rounded,
                              color: Colors.white, size: 56),
                          SizedBox(height: 6),
                          Text(
                            'برای اسکن بعدی بزنید',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
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

class _CameraError extends StatelessWidget {
  const _CameraError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1A1F),
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_photography_rounded, color: Colors.white70, size: 48),
            SizedBox(height: 12),
            Text(
              'دسترسی به دوربین ممکن نیست.\nاجازه دوربین را در تنظیمات گوشی فعال کنید یا کد را دستی وارد کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final Animation<double> progress;
  final bool showLine;

  _FramePainter({required this.progress, required this.showLine})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.72;
    final h = size.height * 0.56;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 10),
      width: w,
      height: h,
    );

    final bracket = Paint()
      ..color = AppColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 30.0;
    final l = rect.left, r = rect.right, t = rect.top, b = rect.bottom;

    canvas.drawLine(Offset(l, t + len), Offset(l, t), bracket);
    canvas.drawLine(Offset(l, t), Offset(l + len, t), bracket);
    canvas.drawLine(Offset(r - len, t), Offset(r, t), bracket);
    canvas.drawLine(Offset(r, t), Offset(r, t + len), bracket);
    canvas.drawLine(Offset(l, b - len), Offset(l, b), bracket);
    canvas.drawLine(Offset(l, b), Offset(l + len, b), bracket);
    canvas.drawLine(Offset(r - len, b), Offset(r, b), bracket);
    canvas.drawLine(Offset(r, b), Offset(r, b - len), bracket);

    if (showLine) {
      final y = rect.top + 8 + (rect.height - 16) * progress.value;
      final line = Paint()
        ..color = AppColors.cyan
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
      canvas.drawLine(Offset(rect.left + 6, y), Offset(rect.right - 6, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) => old.showLine != showLine;
}
