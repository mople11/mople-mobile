import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/controllers/settings_controller.dart';
import 'package:mople_mobile/presentation/pages/auth/view/login_page.dart';
import 'package:mople_mobile/presentation/pages/my/view/profile_edit_page.dart';
import 'package:mople_mobile/presentation/pages/policy/view/policy_page.dart';

/// 앱 설정 — `GET /settings`, `PATCH /settings`.
///
/// 서버가 다루는 항목(푸시·골든아워 알림, 언어, 위치 권한)만 실제로 저장되고,
/// 그 밖의 항목은 아직 서버 스펙이 없어 화면 안에서만 유지된다.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // ── 서버에 저장되지 않는 로컬 전용 항목 ──────────────────
  bool _rainPreference = true;
  String _region = '순천시';
  String _transport = '자동차';

  static const _regions = ['순천시', '여수시', '담양군', '보성군', '완도군', '목포시'];
  static const _transports = ['자동차', '대중교통', '도보', '자전거'];

  static const _languageLabels = {
    AppLanguage.ko: '한국어',
    AppLanguage.en: 'English',
    AppLanguage.ja: '日本語',
    AppLanguage.zh: '中文',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).load());
  }

  void _flash(String message) {
    AppToast.show(context, title: '알림', message: message);
  }

  /// 서버 저장 결과에 따라 성공/실패 토스트를 띄운다.
  Future<void> _patch(Future<bool> Function() action, String label) async {
    final ok = await action();
    if (!mounted) return;
    if (ok) {
      _flash(label);
    } else {
      final error = ref.read(settingsProvider).updateAction;
      AppToast.show(
        context,
        title: '저장 실패',
        message: error?.error is ApiError
            ? (error!.error as ApiError).displayMessage
            : '설정을 저장하지 못했어요.',
        tone: AppToastTone.danger,
      );
    }
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
      onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
        if (!mounted) return;
        ref.read(mainTabProvider.notifier).switchTab('home');
        context.pushAndRemoveAll(const LoginPage());
      },
    );
  }

  /// 회원탈퇴 확인 다이얼로그.
  ///
  /// 스토어 정책상 계정을 만들 수 있는 앱은 앱 안에서 계정 삭제도 제공해야
  /// 한다. 서버 탈퇴 API 는 아직 백엔드 스펙 확정 전이라, 지금은 확인 후
  /// 로컬 세션만 정리하고 로그인 화면으로 되돌린다.
  void _confirmDeleteAccount() {
    AppDialog.show<void>(
      context,
      title: '정말 탈퇴하시겠어요?',
      description: '탈퇴하면 저장한 코스, 후기, 좋아요 등 모든 데이터가 삭제되며 '
          '복구할 수 없어요.',
      actions: [
        Builder(
          builder: (dialogContext) => TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteAccount();
            },
            child: const Text('탈퇴하기'),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAccount() async {
    // TODO(backend): 서버 탈퇴 API(예: DELETE /users/me)가 확정되면 여기서
    // 호출한 뒤 세션을 정리한다. 지금은 로컬 세션 정리만 수행한다.
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    ref.read(mainTabProvider.notifier).switchTab('home');
    context.pushAndRemoveAll(const LoginPage());
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
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
                label: '푸시 알림',
                trailing: AppSwitch(
                  value: settings.pushEnabled,
                  onChanged: (v) => _patch(
                    () => notifier.setPush(v),
                    v ? '푸시 알림을 켰어요.' : '푸시 알림을 꺼요.',
                  ),
                ),
              ),
              _SettingsRow(
                label: '골든아워 알림',
                trailing: AppSwitch(
                  value: settings.goldenHourEnabled,
                  onChanged: (v) => _patch(
                    () => notifier.setGoldenHour(v),
                    v ? '골든아워 알림을 켰어요.' : '골든아워 알림을 꺼요.',
                  ),
                ),
              ),
              _SettingsRow(
                label: '위치 권한',
                trailing: AppSwitch(
                  value: settings.locationGranted,
                  onChanged: (v) => _patch(
                    () => notifier.setLocationPermission(v),
                    v ? '위치 권한을 허용했어요.' : '위치 권한을 껐어요.',
                  ),
                ),
              ),
              _SettingsRow(
                label: '언어',
                onTap: () => _pickOption(
                  title: '언어',
                  options: _languageLabels.values.toList(),
                  value: _languageLabels[settings.language] ?? '한국어',
                  onSelected: (label) {
                    final lang = _languageLabels.entries
                        .firstWhere((e) => e.value == label)
                        .key;
                    _patch(
                      () => notifier.setLanguage(lang),
                      '언어를 $label(으)로 변경했어요.',
                    );
                  },
                ),
                trailing: _ValueTrailing(
                  _languageLabels[settings.language] ?? '한국어',
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
                trailing: _ValueTrailing(_region),
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
                trailing: _ValueTrailing(_transport),
              ),
              _SettingsRow(
                label: '우천 시 실내 코스 우선',
                trailing: AppSwitch(
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
                trailing: const _Chevron(),
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
                onTap: () => context.push(const PolicyPage.terms()),
                trailing: const _Chevron(),
              ),
              _SettingsRow(
                label: '개인정보처리방침',
                onTap: () => context.push(const PolicyPage.privacy()),
                trailing: const _Chevron(),
              ),
              _SettingsRow(
                label: '문의하기',
                onTap: () => _comingSoon('문의하기'),
                trailing: const _Chevron(),
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
          const SizedBox(height: AppSpacing.space3),
          // 계정 삭제 진입점. 스토어(구글 플레이 계정 삭제 요건) 심사 대응을
          // 위해 로그아웃과 나란히, 눈에 띄는 위치에 둔다.
          Center(
            child: AppTextLink(
              label: '회원탈퇴',
              tone: AppTextLinkTone.plain,
              onTap: _confirmDeleteAccount,
            ),
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

/// "값 + 화살표" 형태의 행 우측 요소. 선택형 설정 행이 모두 같은 모양이라
/// 한 곳에서 정의한다.
class _ValueTrailing extends StatelessWidget {
  const _ValueTrailing(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyle.body.copyWith(color: AppColors.textTertiary),
        ),
        const _Chevron(size: 15),
      ],
    );
  }
}

/// 다음 화면으로 이동하는 행의 우측 화살표.
class _Chevron extends StatelessWidget {
  const _Chevron({this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: size,
      color: AppColors.textTertiary,
    );
  }
}
