import 'package:flutter/material.dart';

import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onTab});

  final ValueChanged<int>? onTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                _Header(),
                SizedBox(height: 16),
                _SearchBar(),
                SizedBox(height: 6),
                _QuickActions(),
                SizedBox(height: 14),
                _SectionHeader(title: 'Current Shipment'),
                SizedBox(height: 10),
                _CurrentShipmentCard(),
                SizedBox(height: 20),
                _SectionHeader(title: 'Recent Shipment'),
                SizedBox(height: 10),
                _RecentCard(
                  image: AppImages.macMini,
                  id: 'ID: H314315796',
                  name: 'Mac Mini M4 Pro',
                  status: 'On Process',
                ),
                SizedBox(height: 12),
                _RecentCard(
                  image: AppImages.speaker,
                  id: 'ID: K37856307',
                  name: 'Sony Speaker',
                  status: 'Delivered',
                ),
                SizedBox(height: 12),
                _RecentCard(
                  image: AppImages.drone,
                  id: 'ID: K37956307',
                  name: 'DJI Drone',
                  status: 'Pending',
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: FloatingNavBar(onTab: onTab),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            child: Center(
              child: _HomeIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 26, color: AppColors.textDark),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery to',
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
            SizedBox(height: 2),
            Text(
              '1/12 Diriyah, Riyadh',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 24, color: AppColors.textDark),
            Positioned(
              right: 1,
              top: 0,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: AppColors.textGrey),
                SizedBox(width: 8),
                Text('Search', style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(color: AppColors.navDark, shape: BoxShape.circle),
          child: const Icon(Icons.document_scanner_outlined, size: 22, color: Colors.white),
        ),
      ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(left: 32, top: 22, child: _QuickLabel('New\nDelivery')),
          Positioned(
            left: 82,
            top: 0,
            child: Image.asset(AppImages.truckRed, width: 108, height: 110, fit: BoxFit.contain),
          ),
          const Positioned(left: 212, top: 22, child: _QuickLabel('Track\nPackage')),
          Positioned(
            right: 0,
            top: 10,
            child: Image.asset(AppImages.box, width: 110, height: 95, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _QuickLabel extends StatelessWidget {
  const _QuickLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          const Spacer(),
          const Text('See All', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
      ),
    );
  }
}

/// Space kept free on the right of the Current Shipment card for the parcel
/// artwork, so the progress track and the date labels both stop where the box
/// begins instead of sliding underneath it.
const double _artworkReserve = 108;

class _CurrentShipmentCard extends StatelessWidget {
  const _CurrentShipmentCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        _ProductThumb(image: AppImages.macMini, size: 42, radius: 12),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: H314315796',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Mac Mini M4 Pro',
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                        _GreyPill(label: 'Transit'),
                      ],
                    ),
                    SizedBox(height: 22),
                    Padding(
                      padding: EdgeInsets.only(right: _artworkReserve),
                      child: _ShipmentProgress(),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(right: _artworkReserve),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 135,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '18 Oct 2025',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ),
                                SizedBox(height: 3),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Diriyah, Riyadh',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Estimated 19 Oct 2025',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ),
                                SizedBox(height: 3),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Jawhra, Jeddah',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -14,
                top: 70,
                width: 110,
                height: 122,
                child: Image.asset(AppImages.boxBig, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.image, required this.size, required this.radius});

  final String image;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(image, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _GreyPill extends StatelessWidget {
  const _GreyPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.pillGreyBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMidGrey),
      ),
    );
  }
}

class _ShipmentProgress extends StatelessWidget {
  const _ShipmentProgress();

  @override
  Widget build(BuildContext context) {
    // Fills the width left over by [_artworkReserve] so the four nodes always
    // sit on equal thirds of the track, first node flush with the card padding
    // and the last node ending just before the parcel artwork.
    return SizedBox(
      height: 34,
      width: double.infinity,
      child: Row(
        children: const [
          _ProgressNode(done: true),
          _DottedSegment(done: true),
          _ProgressNode(done: true),
          _DottedSegment(done: true),
          _TruckNode(),
          _DottedSegment(done: false),
          _ProgressNode(done: false),
        ],
      ),
    );
  }
}

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.orange : Colors.white,
        border: Border.all(
          color: done ? AppColors.orange : const Color(0xFFC9CCD1),
          width: 1.4,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 7, color: Colors.white)
          : null,
    );
  }
}

class _TruckNode extends StatelessWidget {
  const _TruckNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFECEAE8)),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(AppImages.truckRed, fit: BoxFit.contain),
          ),
          const Positioned(
            top: -12,
            child: Text(
              '4h Away',
              maxLines: 1,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedSegment extends StatelessWidget {
  const _DottedSegment({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomPaint(
        size: const Size(double.infinity, 9),
        painter: _DottedLinePainter(color: done ? AppColors.orange : const Color(0xFFD4D6DA)),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const dotRadius = 1.0;
    const gap = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawCircle(Offset(x + dotRadius, y), dotRadius, paint);
      x += dotRadius * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.image,
    required this.id,
    required this.name,
    required this.status,
  });

  final String image;
  final String id;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(image, width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 3),
                  Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            _GreyPill(label: status),
          ],
        ),
      ),
    );
  }
}

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, this.onTab});

  final ValueChanged<int>? onTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.navDark,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            const _NavActiveItem(icon: Icons.home_rounded, label: 'Home'),
            _NavItem(
              icon: Icons.work_outline_rounded,
              label: 'Shipment',
              onTap: () => onTab?.call(1),
            ),
            _NavPlus(onTap: () {}),
            _NavItem(
              icon: Icons.location_on_outlined,
              label: 'Tracking',
              onTap: () => onTab?.call(1),
            ),
            const _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _NavActiveItem extends StatelessWidget {
  const _NavActiveItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          width: 56,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textDark),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: AppColors.navInactive),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.navInactive),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPlus extends StatelessWidget {
  const _NavPlus({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orange,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x55FF6B2B), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
