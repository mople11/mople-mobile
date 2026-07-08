import 'package:flutter/material.dart';

/// 어디가남 Design System — Color tokens.
/// 바다(Blue) · 숲(Green) · 햇살(Orange)에서 영감을 받은 브랜드 팔레트와 슬레이트 중립색.
abstract final class AppColors {
  // ---- Ocean Blue (primary) ----
  static const Color blue50 = Color(0xFFE9F3FD);
  static const Color blue100 = Color(0xFFCFE5FB);
  static const Color blue200 = Color(0xFFA7CFF7);
  static const Color blue300 = Color(0xFF6FB2F1);
  static const Color blue400 = Color(0xFF4A9DED);
  static const Color blue500 = Color(0xFF1E88E5); // Primary — Ocean Blue
  static const Color blue600 = Color(0xFF1A78CC);
  static const Color blue700 = Color(0xFF1565B0);
  static const Color blue800 = Color(0xFF114F8A);
  static const Color blue900 = Color(0xFF0D3A66);

  // ---- Nature Green (secondary) ----
  static const Color green50 = Color(0xFFEAF6EC);
  static const Color green100 = Color(0xFFCDE9D2);
  static const Color green200 = Color(0xFFA6D6AE);
  static const Color green300 = Color(0xFF74BE80);
  static const Color green400 = Color(0xFF57B063);
  static const Color green500 = Color(0xFF43A047); // Secondary — Nature Green
  static const Color green600 = Color(0xFF3A8C3F);
  static const Color green700 = Color(0xFF2F7334);
  static const Color green800 = Color(0xFF255A29);
  static const Color green900 = Color(0xFF1B421E);

  // ---- Warm Orange (accent) ----
  static const Color orange50 = Color(0xFFFFF6E1);
  static const Color orange100 = Color(0xFFFFE9B3);
  static const Color orange200 = Color(0xFFFFDA80);
  static const Color orange300 = Color(0xFFFFCB4D);
  static const Color orange400 = Color(0xFFFFBF26);
  static const Color orange500 = Color(0xFFFFB300); // Accent — Warm Sunshine
  static const Color orange600 = Color(0xFFE6A100);
  static const Color orange700 = Color(0xFFCC8F00);
  static const Color orange800 = Color(0xFFA67400);
  static const Color orange900 = Color(0xFF805900);

  // ---- Neutral (slate) ----
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8FAFC); // Page background
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ---- Raw semantic hues ----
  static const Color red500 = Color(0xFFE53935);
  static const Color red50 = Color(0xFFFDECEA);
  static const Color amber500 = Color(0xFFFFB300);
  static const Color amber50 = Color(0xFFFFF6E1);

  // ================= SEMANTIC ALIASES =================

  // Brand
  static const Color brandPrimary = blue500;
  static const Color brandPrimaryHover = blue600;
  static const Color brandPrimaryPress = blue700;
  static const Color brandSecondary = green500;
  static const Color brandAccent = orange500;

  // Surfaces
  static const Color surfacePage = neutral50;
  static const Color surfaceCard = neutral0;
  static const Color surfaceRaised = neutral0;
  static const Color surfaceSunken = neutral100;
  static const Color surfaceInverse = neutral900;
  static const Color surfaceOverlay = Color(0x7A0F172A); // rgba(15,23,42,0.48)

  // Text
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textTertiary = neutral400;
  static const Color textInverse = neutral0;
  static const Color textBrand = blue600;
  static const Color textOnBrand = neutral0;

  // Borders
  static const Color borderSubtle = neutral200;
  static const Color borderDefault = neutral300;
  static const Color borderStrong = neutral400;
  static const Color borderBrand = blue500;

  // Semantic status
  static const Color success = green500;
  static const Color successBg = green50;
  static const Color successText = green700;
  static const Color warning = orange500;
  static const Color warningBg = orange50;
  static const Color warningText = orange800;
  static const Color danger = red500;
  static const Color dangerBg = red50;
  static const Color dangerText = Color(0xFFB71C1C);
  static const Color info = blue500;
  static const Color infoBg = blue50;
  static const Color infoText = blue700;

  // Interactive fills
  static const Color fillHover = Color(0x0A0F172A); // rgba(15,23,42,0.04)
  static const Color fillPress = Color(0x140F172A); // rgba(15,23,42,0.08)
  static const Color fillBrandSoft = blue50;

  // Focus ring
  static const Color ringBrand = Color(0x4D1E88E5); // rgba(30,136,229,0.30)
  static const Color ringDanger = Color(0x47E53935); // rgba(229,57,53,0.28)
}
