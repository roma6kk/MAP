import 'package:flutter/material.dart';

import '../theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onBack: onBack),
            const SizedBox(height: 12),
            const Expanded(child: _MapArea()),
            const _DetailsSheet(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 19, color: AppColors.textDark),
            ),
          ),
          const Expanded(
            child: Text(
              'Location Tracking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
          const SizedBox(
            width: 38,
            child: Icon(Icons.more_vert_rounded, size: 22, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  const _MapArea();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.mapBase,
      fit: BoxFit.fill,
      alignment: Alignment.topCenter,
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheetDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 0, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF5A5D63),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Id:', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      SizedBox(height: 6),
                      Text(
                        'H314315796',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // 'Status:' and the pill below it share one left edge while the
                // pill keeps the sheet's right padding, matching the reference.
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status:', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        SizedBox(height: 8),
                        _StatusPill(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: _Checkpoints(),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Col(label: 'Created, 18 Oct 2025', value: 'Diriyah, Riyadh'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _Col(label: 'Estimated, 19 Oct 2025', value: 'Jawhra, Jeddah', alignEnd: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                top: -4,
                bottom: -12,
                width: 112,
                child: Image.asset(AppImages.boxBig, fit: BoxFit.contain, alignment: Alignment.centerRight),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 96),
                child: Column(
                  children: const [
                    Row(
                      children: [
                        Expanded(child: _Col(label: 'From', value: 'Diriyah, Riyadh')),
                        SizedBox(width: 12),
                        Expanded(child: _Col(label: 'To', value: 'Jawhra, Jeddah')),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _Col(label: 'Customer', value: 'Ahmad Kawsar')),
                        SizedBox(width: 12),
                        Expanded(child: _Col(label: 'Order Cost', value: '\$120.00')),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _Col(label: 'Quantity', value: '1 Box')),
                        SizedBox(width: 12),
                        Expanded(child: _Col(label: 'Weight', value: '10 Kg')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sheetCard,
                borderRadius: BorderRadius.circular(34),
              ),
              child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(AppImages.courier),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khalid Omor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text('Courier', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                ),
                _RoundAction(icon: Icons.call_rounded, background: AppColors.orange, iconColor: Colors.white),
                SizedBox(width: 10),
                _RoundAction(
                  icon: Icons.mode_comment_rounded,
                  background: Colors.white,
                  iconColor: AppColors.textDark,
                ),
              ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: _SheetHomeIndicator(),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.sheetCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Transit',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }
}

class _SheetHomeIndicator extends StatelessWidget {
  const _SheetHomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
    );
  }
}

class _Checkpoints extends StatelessWidget {
  const _Checkpoints();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: const [
          _Checkpoint(current: true),
          Expanded(child: _DashLine()),
          _Checkpoint(),
          Expanded(child: _DashLine()),
          _Checkpoint(),
          Expanded(child: _DashLine()),
          _Checkpoint(),
        ],
      ),
    );
  }
}

class _Checkpoint extends StatelessWidget {
  const _Checkpoint({this.current = false});

  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: current ? Colors.white : const Color(0xFF3A3D44),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 16,
        color: current ? AppColors.textDark : Colors.white,
      ),
    );
  }
}

class _DashLine extends StatelessWidget {
  const _DashLine();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 22),
      painter: _DashLinePainter(),
    );
  }
}

class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A5D63)
      ..strokeWidth = 1.6;
    const dash = 3.0;
    const gap = 3.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Col extends StatelessWidget {
  const _Col({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 19, color: iconColor),
    );
  }
}
