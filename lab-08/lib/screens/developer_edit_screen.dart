import 'package:flutter/material.dart';

import '../db/developer_db.dart';
import '../models/developer.dart';

class DeveloperEditScreen extends StatefulWidget {
  const DeveloperEditScreen({super.key, this.developer});
  final Developer? developer;

  @override
  State<DeveloperEditScreen> createState() => _DeveloperEditScreenState();
}

class _DeveloperEditScreenState extends State<DeveloperEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.developer?.name);
  late final _specialty =
      TextEditingController(text: widget.developer?.specialty);
  late final _salary = TextEditingController(
      text: widget.developer?.salary.toStringAsFixed(0));
  late final _cups =
      TextEditingController(text: '${widget.developer?.cupsOfCoffee ?? 0}');
  late String _role = widget.developer?.role ?? Developer.roles.first;

  bool get _isEdit => widget.developer != null;

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    _salary.dispose();
    _cups.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final d = Developer(
      id: widget.developer?.id,
      name: _name.text.trim(),
      specialty: _specialty.text.trim(),
      role: _role,
      salary: double.parse(_salary.text.replaceAll(',', '.')),
      cupsOfCoffee: int.parse(_cups.text),
    );
    if (_isEdit) {
      await DeveloperDb.instance.update(d);
    } else {
      await DeveloperDb.instance.insert(d);
    }
    if (mounted) Navigator.pop(context);
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Изменить' : 'Добавить')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Имя'),
              validator: _required,
            ),
            TextFormField(
              controller: _specialty,
              decoration: const InputDecoration(labelText: 'Специальность'),
              validator: _required,
            ),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Роль'),
              items: [
                for (final r in Developer.roles)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) => setState(() => _role = v!),
            ),
            TextFormField(
              controller: _salary,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Зарплата'),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                return (n == null || n <= 0) ? 'Положительное число' : null;
              },
            ),
            TextFormField(
              controller: _cups,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Чашек кофе'),
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Целое число' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}
