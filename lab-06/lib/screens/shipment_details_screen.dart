import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/shipment.dart';
import '../theme.dart';

const _statuses = ['Transit', 'On Process', 'Pending', 'Delivered'];

class ShipmentDetailsScreen extends StatefulWidget {
  const ShipmentDetailsScreen({super.key, required this.shipment});

  final Shipment shipment;

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus() async {
    final status = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in _statuses)
              ListTile(
                title: Text(option),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      ),
    );
    if (status == null || !mounted) return;
    Navigator.of(context).pop(status);
  }

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final images = [shipment.image, AppImages.boxBig, AppImages.courier];
    final captions = ['Товар', 'Упаковка', 'Курьер'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shipment Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: AppColors.pillGreyBg,
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(images[index], fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _page ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _page ? AppColors.orange : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                captions[_page],
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 24),
            _DetailField(label: 'Booking Id', value: 'ID: ${shipment.id}'),
            const SizedBox(height: 18),
            _DetailField(label: 'Product', value: shipment.name),
            const SizedBox(height: 18),
            _DetailField(label: 'Status', value: shipment.status),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Открыть трекинг (replace)'),
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.tracking,
                  arguments: shipment.id,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Изменить статус (pop с результатом)'),
                onPressed: _changeStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
      ],
    );
  }
}
