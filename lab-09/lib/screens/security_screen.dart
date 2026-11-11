import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/security_provider.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityProvider>();
    final busy = security.busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Security / storage')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Боксы зашифрованы AES-256. Ключ лежит в защищённом хранилище ОС '
                '(flutter_secure_storage).'),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: busy ? null : () => context.read<SecurityProvider>().demoWrongKey(),
                child: const Text('Прочитать с неправильным ключом')),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: busy ? null : () => context.read<SecurityProvider>().compactAll(),
                child: const Text('Сжать боксы (compact)')),
            const SizedBox(height: 16),
            if (busy) const LinearProgressIndicator(),
            Expanded(child: SingleChildScrollView(child: SelectableText(security.log))),
          ],
        ),
      ),
    );
  }
}
