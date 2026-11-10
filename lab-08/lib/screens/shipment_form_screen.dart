import 'package:flutter/material.dart';

import '../models/shipment.dart';
import '../services/hive_service.dart';
import '../services/session.dart';
import '../theme.dart';

class ShipmentFormScreen extends StatefulWidget {
  const ShipmentFormScreen({super.key, this.shipment});
  final Shipment? shipment;

  @override
  State<ShipmentFormScreen> createState() => _ShipmentFormScreenState();
}

class _ShipmentFormScreenState extends State<ShipmentFormScreen> {
  static const _images = [AppImages.macMini, AppImages.speaker, AppImages.drone, AppImages.box];
  static const _statuses = ['Pending', 'On Process', 'Transit', 'Delivered'];

  final _form = GlobalKey<FormState>();
  late final _id = TextEditingController(text: widget.shipment?.id);
  late final _name = TextEditingController(text: widget.shipment?.name);
  late final _from = TextEditingController(text: widget.shipment?.fromPlace);
  late final _to = TextEditingController(text: widget.shipment?.toPlace);
  late final _sent = TextEditingController(text: widget.shipment?.sentDate);
  late final _est = TextEditingController(text: widget.shipment?.estimatedDate);
  late final _desc = TextEditingController(text: widget.shipment?.description);
  late String _image = widget.shipment?.image ?? _images.first;
  late String _status = widget.shipment?.status ?? _statuses.first;

  bool get _editing => widget.shipment != null;

  @override
  Widget build(BuildContext context) {
    if (!Session.instance.user.canEdit) {
      return const Scaffold(body: Center(child: Text('Недостаточно прав')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit shipment' : 'New shipment')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _id,
              enabled: !_editing,
              decoration: const InputDecoration(labelText: 'ID'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                if (!_editing && HiveService.instance.shipments.containsKey(v.trim())) return 'ID уже существует';
                return null;
              },
            ),
            _field(_name, 'Name'),
            DropdownButtonFormField<String>(
              initialValue: _image,
              decoration: const InputDecoration(labelText: 'Image (asset path)'),
              items: [for (final i in _images) DropdownMenuItem(value: i, child: Text(i.split('/').last))],
              onChanged: (v) => _image = v!,
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [for (final s in _statuses) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => _status = v!,
            ),
            _field(_from, 'From'),
            _field(_to, 'To'),
            _field(_sent, 'Sent date'),
            _field(_est, 'Estimated date'),
            _field(_desc, 'Description', lines: 3),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int lines = 1}) => TextFormField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null,
      );

  Future<void> _save() async {
    if (!_form.currentState!.validate() || !Session.instance.user.canEdit) return;
    final s = Shipment(
      id: _id.text.trim(),
      image: _image,
      name: _name.text.trim(),
      status: _status,
      fromPlace: _from.text.trim(),
      toPlace: _to.text.trim(),
      sentDate: _sent.text.trim(),
      estimatedDate: _est.text.trim(),
      description: _desc.text.trim(),
    );
    await HiveService.instance.shipments.put(s.id, s);
    if (mounted) Navigator.pop(context);
  }
}
