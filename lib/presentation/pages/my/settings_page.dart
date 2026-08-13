import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';
import 'package:mople_mobile/presentation/pages/my/profile_edit_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _lang = '한국어';
  bool _tripAlert = true;
  bool _weatherAlert = true;
  bool _reviewAlert = false;
  bool _rainPreference = true;
  String _region = '순천시';
  String _transport = '자동차';

  static const _regions = ['순천시', '여수시', '담양군', '보성군', '완도군', '목포시'];
  static const _transports = ['자동차', '대중교통', '도보', '자전거'];

  void _flash(String message) {
    AppToast.show(context, title: '알림', message: message);
  }

  void _comingSoon(String feature) {
    AppToast.show(
      context,
      title: '준비 중이에요',
      message: '$feature 기능은 곧 만나보실 수 있어요.',
      tone: AppToastTone.info,
    );
  }

  void _confirmLogout() {
    AppDialog.confirmLogout(
      context,
      onConfirm: () {
        ref.read(mainTabProvider.notifier).switchTab('home');
        context.pushAndRemoveAll(const LoginPage());
      },
    );
  }

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required String value,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
              ),
              const SizedBox(height: AppSpacing.space3),
              for (final o in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o, style: AppTextStyle.body),
                  trailing: o == value
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.brandPrimary,
                        )
                      : null,
                  onTap: () {
                    onSelected(o);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '설정',
      onBack: () => context.pop(),
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
              _SettingsRow(
                label: '기본 출발 지역',
                onTap: () => _pickOption(
                  title: '기본 출발 지역',
                  options: _regions,
                  value: _region,
                  onSelected: (v) {
                    setState(() => _region = v);
                    _flash('기본 출발 지역을 $v(으)로 변경했어요.');
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _region,
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              _SettingsRow(
                label: '선호 이동수단',
                onTap: () => _pickOption(
                  title: '선호 이동수단',
                  options: _transports,
                  value: _transport,
                  onSelected: (v) {
                    setState(() => _transport = v);
                    _flash('선호 이동수단을 $v(으)로 변경했어요.');
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _transport,
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                    const Icon(
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
              _SettingsRow(
                label: '회원정보 관리',
                onTap: () => context.push(ProfileEditPage()),
                trailing: const Icon(
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
            rows: [
              _SettingsRow(
                label: '이용약관',
                onTap: () => _comingSoon('이용약관'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              _SettingsRow(
                label: '개인정보처리방침',
                onTap: () => _comingSoon('개인정보처리방침'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
              _SettingsRow(
                label: '문의하기',
                onTap: () => _comingSoon('문의하기'),
                trailing: const Icon(
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
  const _SettingsRow({required this.label, required this.trailing, this.onTap});

  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
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

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
