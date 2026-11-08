import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const orange = Color(0xFFFF6B2B);
  static const orangeHalo = Color(0x33FF6B2B);
  static const textDark = Color(0xFF17181C);
  static const textGrey = Color(0xFF9CA0A8);
  static const textMidGrey = Color(0xFF6B7076);
  static const cardBorder = Color(0xFFEFF0F3);
  static const pillGreyBg = Color(0xFFF1F2F4);
  static const navDark = Color(0xFF17181D);
  static const navInactive = Color(0xFF9A9EA6);
  static const sheetDark = Color(0xFF1F2126);
  static const sheetCard = Color(0xFF2A2D33);
  static const sheetLine = Color(0xFF43464C);
  static const mapBg = Color(0xFFEBECE6);
  static const roadWhite = Color(0xFFFFFFFF);
  static const routeDark = Color(0xFF3B3D42);
}

class AppImages {
  AppImages._();

  static const truckRed = 'assets/images/truck_red.png';
  static const box = 'assets/images/box.png';
  static const boxBig = 'assets/images/box_big.png';
  static const macMini = 'assets/images/mac_mini.jpg';
  static const speaker = 'assets/images/speaker.jpg';
  static const drone = 'assets/images/drone.jpg';
  static const courier = 'assets/images/courier.jpg';
  static const mapBase = 'assets/images/map_basecopy.png';
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.orange,
        surface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
    );
  }
}
