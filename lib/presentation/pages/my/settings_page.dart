import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _lang = '한국어';
  bool _tripAlert = true;
  bool _weatherAlert = true;
  bool _reviewAlert = false;
  bool _rainPreference = true;

  void _flash(String message) {
    AppToast.show(context, title: '알림', message: message);
  }

  void _confirmLogout() {
    AppDialog.confirmLogout(
      context,
      onConfirm: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '설정',
      onBack: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsGroup(
            title: '알림',
            rows: [
              _SettingsRow(
                label: '여행 추천 알림',
                trailing: Switch(
                  value: _tripAlert,
                  onChanged: (v) {
                    setState(() => _tripAlert = v);
                    _flash(v ? '여행 추천 알림을 켰어요.' : '여행 추천 알림을 꺼요.');
                  },
                ),
              ),
              _SettingsRow(
                label: '날씨 변화 알림',
                trailing: Switch(
                  value: _weatherAlert,
                  onChanged: (v) {
                    setState(() => _weatherAlert = v);
                    _flash(v ? '날씨 변화 알림을 켰어요.' : '날씨 변화 알림을 꺼요.');
                  },
                ),
              ),
              _SettingsRow(
                label: '리뷰 · 좋아요 알림',
                trailing: Switch(
                  value: _reviewAlert,
                  onChanged: (v) {
                    setState(() => _reviewAlert = v);
                    _flash(v ? '리뷰 알림을 켰어요.' : '리뷰 알림을 꺼요.');
                  },
                ),
              ),
            ],
          ),
          _SettingsGroup(
            title: '여행 설정',
            rows: [
              const _SettingsRow(
                label: '기본 출발 지역',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '순천시',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              const _SettingsRow(
                label: '선호 이동수단',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '자동차',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              _SettingsRow(
                label: '우천 시 실내 코스 우선',
                trailing: Switch(
                  value: _rainPreference,
                  onChanged: (v) {
                    setState(() => _rainPreference = v);
                    _flash(v ? '우천 시 실내 코스를 우선해요.' : '설정을 꺼요.');
                  },
                ),
              ),
            ],
          ),
          _SettingsGroup(
            title: '계정',
            rows: [
              const _SettingsRow(
                label: '회원정보 관리',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              _SettingsRow(
                label: '언어',
                trailing: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final l in ['한국어', 'English'])
                        GestureDetector(
                          onTap: () {
                            if (l == _lang) return;
                            setState(() => _lang = l);
                            _flash(
                              l == 'English'
                                  ? 'Language changed to English.'
                                  : '언어가 한국어로 변경됐어요.',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space3,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _lang == l
                                  ? AppColors.surfaceCard
                                  : Colors.transparent,
                              borderRadius: AppRadius.radiusPill,
                            ),
                            child: Text(
                              l,
                              style: AppTextStyle.small.copyWith(
                                fontWeight: _lang == l
                                    ? AppFont.bold
                                    : AppFont.medium,
                                color: _lang == l
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const _SettingsRow(
                label: '버전',
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          _SettingsGroup(
            title: '약관',
            rows: const [
              _SettingsRow(
                label: '이용약관',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              _SettingsRow(
                label: '개인정보처리방침',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              _SettingsRow(
                label: '문의하기',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          AppButton(
            label: '로그아웃',
            variant: AppButtonVariant.outline,
            width: double.infinity,
            leading: const Icon(
              Icons.logout_rounded,
              size: 17,
              color: AppColors.textBrand,
            ),
            onPressed: _confirmLogout,
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyle.small.copyWith(
              color: AppColors.textTertiary,
              fontWeight: AppFont.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          ...rows,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyle.body)),
          trailing,
        ],
      ),
    );
  }
}
