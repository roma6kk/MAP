import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../platform/native_channels.dart';
import '../theme.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final _subjectController = TextEditingController(text: 'Заказ H314315796');
  final _picker = ImagePicker();

  String? _light;
  BatteryInfo? _battery;
  String? _batteryError;
  String? _mailMessage;
  File? _photo;
  String? _photoError;

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  String _describe(Object error) {
    if (error is PlatformException) return error.message ?? error.code;
    return error.toString();
  }

  Future<void> _readLight() async {
    try {
      final lux = await NativeChannels.lightLevel();
      if (!mounted) return;
      setState(() => _light = '${lux.toStringAsFixed(1)} lx');
    } catch (error) {
      if (!mounted) return;
      setState(() => _light = _describe(error));
    }
  }

  Future<void> _readBattery() async {
    try {
      final info = await NativeChannels.batteryInfo();
      if (!mounted) return;
      setState(() {
        _battery = info;
        _batteryError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _battery = null;
        _batteryError = _describe(error);
      });
    }
  }

  Future<void> _openMail() async {
    try {
      final opened = await NativeChannels.openMail(_subjectController.text);
      if (!mounted) return;
      setState(() => _mailMessage = opened ? 'Почтовое приложение открыто' : 'Не удалось открыть почту');
    } catch (error) {
      if (!mounted) return;
      setState(() => _mailMessage = _describe(error));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (shot == null || !mounted) return;
      setState(() {
        _photo = File(shot.path);
        _photoError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _photoError = _describe(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Device Features'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _FeatureCard(
            title: 'Датчик освещённости',
            subtitle: 'Platform Method Channel lab06/sensors. Android: SensorManager, TYPE_LIGHT. iOS: публичного API нет, канал возвращает ошибку UNSUPPORTED.',
            children: [
              _ActionButton(label: 'Измерить освещённость', onPressed: _readLight),
              if (_light != null) _ResultText(_light!),
            ],
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Заряд батареи',
            subtitle: 'Platform Method Channel lab06/battery. Android: BatteryManager. iOS: UIDevice.batteryLevel.',
            children: [
              _ActionButton(label: 'Получить заряд', onPressed: _readBattery),
              if (_battery != null) ...[
                _ResultText('${_battery!.level} %'),
                const SizedBox(height: 4),
                Text(
                  '${_battery!.platform}: ${_battery!.api}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
              if (_batteryError != null) _ResultText(_batteryError!),
            ],
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Почта с темой',
            subtitle: 'Platform Method Channel lab06/apps передаёт тему из поля ввода в приложение почты.',
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Тема письма',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _ActionButton(label: 'Открыть почту', onPressed: _openMail),
              if (_mailMessage != null) _ResultText(_mailMessage!),
            ],
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Фото с камеры',
            subtitle: 'Пакет image_picker открывает камеру и отображает снимок.',
            children: [
              _ActionButton(label: 'Сделать фото', onPressed: _takePhoto),
              if (_photoError != null) _ResultText(_photoError!),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_photo!, height: 220, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
      ),
    );
  }
}
