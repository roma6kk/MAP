import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/shipment.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Shipment _current = const Shipment(
    id: 'H314315796',
    name: 'Mac Mini M4 Pro',
    status: 'Transit',
    image: AppImages.macMini,
  );

  final _recent = <Shipment>[
    const Shipment(
      id: 'H314315796',
      name: 'Mac Mini M4 Pro',
      status: 'On Process',
      image: AppImages.macMini,
    ),
    const Shipment(
      id: 'K37856307',
      name: 'Sony Speaker',
      status: 'Delivered',
      image: AppImages.speaker,
    ),
    const Shipment(
      id: 'K37956307',
      name: 'DJI Drone',
      status: 'Pending',
      image: AppImages.drone,
    ),
  ];

  Future<void> _openCurrent() async {
    final status = await Navigator.of(context).pushNamed<String>(
      AppRoutes.details,
      arguments: _current,
    );
    if (status == null || !mounted) return;
    setState(() => _current = _current.copyWith(status: status));
  }

  Future<void> _openRecent(int index) async {
    final status = await Navigator.of(context).pushNamed<String>(
      AppRoutes.details,
      arguments: _recent[index],
    );
    if (status == null || !mounted) return;
    setState(() => _recent[index] = _recent[index].copyWith(status: status));
  }

  void _openTracking() {
    Navigator.of(context).pushNamed(AppRoutes.tracking, arguments: _current.id);
  }

  void _openDevice() {
    Navigator.of(context).pushNamed(AppRoutes.device);
  }

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
              children: [
                const _Header(),
                const SizedBox(height: 16),
                const _SearchBar(),
                const SizedBox(height: 6),
                _QuickActions(onTrack: _openTracking),
                const SizedBox(height: 14),
                const _SectionHeader(title: 'Current Shipment'),
                const SizedBox(height: 10),
                _CurrentShipmentCard(shipment: _current, onTap: _openCurrent),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Recent Shipment'),
                const SizedBox(height: 10),
                _RecentCard(shipment: _recent[0], onTap: () => _openRecent(0)),
                const SizedBox(height: 12),
                _RecentCard(shipment: _recent[1], onTap: () => _openRecent(1)),
                const SizedBox(height: 12),
                _RecentCard(shipment: _recent[2], onTap: () => _openRecent(2)),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: FloatingNavBar(
              onTracking: _openTracking,
              onProfile: _openDevice,
            ),
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
  const _QuickActions({required this.onTrack});

  final VoidCallback onTrack;

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
          Positioned(
            left: 212,
            top: 22,
            child: _QuickLabel('Track\nPackage', onTap: onTrack),
          ),
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
  const _QuickLabel(this.text, {this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
    if (onTap == null) return label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8), child: label),
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

const double _artworkReserve = 108;

class _CurrentShipmentCard extends StatelessWidget {
  const _CurrentShipmentCard({required this.shipment, required this.onTap});

  final Shipment shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _ProductThumb(image: shipment.image, size: 42, radius: 12),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${shipment.id}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  shipment.name,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          _GreyPill(label: shipment.status),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.only(right: _artworkReserve),
                        child: _ShipmentProgress(),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
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
  const _RecentCard({required this.shipment, required this.onTap});

  final Shipment shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
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
                child: Image.asset(shipment.image, width: 44, height: 44, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${shipment.id}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 3),
                    Text(shipment.name, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
              ),
              _GreyPill(label: shipment.status),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, this.onTracking, this.onProfile});

  final VoidCallback? onTracking;
  final VoidCallback? onProfile;

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
              onTap: onTracking,
            ),
            _NavPlus(onTap: () {}),
            _NavItem(
              icon: Icons.location_on_outlined,
              label: 'Tracking',
              onTap: onTracking,
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: onProfile,
            ),
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
