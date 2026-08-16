import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/main_tab_controller.dart';
import 'package:mople_mobile/presentation/controllers/my_page_controller.dart';
import 'package:mople_mobile/presentation/controllers/stamp_controller.dart';
import 'package:mople_mobile/presentation/controllers/unlock_controller.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';
import 'package:mople_mobile/presentation/pages/my/completion_card_page.dart';
import 'package:mople_mobile/presentation/pages/my/profile_edit_page.dart';
import 'package:mople_mobile/presentation/pages/my/settings_page.dart';
import 'package:mople_mobile/presentation/pages/my/stamp_page.dart';
import 'package:mople_mobile/presentation/pages/my/unlock_page.dart';

/// 마이페이지 — `GET /users/me` 의 프로필·활동 요약.
class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myPageProvider.notifier).loadSummary();
      ref.read(stampProvider.notifier).load();
      ref.read(unlockProvider.notifier).load();
    });
  }

  Future<void> _confirmLogout() async {
    AppDialog.confirmLogout(
      context,
      onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
        if (!mounted) return;
        context.pushAndRemoveAll(const LoginPage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myPage = ref.watch(myPageProvider);
    final stamps = ref.watch(stampProvider);
    final unlock = ref.watch(unlockProvider);
    final profile = myPage.profile;
    final stats = myPage.stats;

    final menu = <(IconData, String, VoidCallback)>[
      (Icons.edit_rounded, '프로필 편집', () => context.push(ProfileEditPage())),
      (
        Icons.map_rounded,
        '내 여행 기록',
        () => ref.read(mainTabProvider.notifier).switchTab('bookmark'),
      ),
      (
        Icons.favorite_rounded,
        '찜한 여행지',
        () => ref.read(mainTabProvider.notifier).switchTab('bookmark'),
      ),
      (
        Icons.photo_album_rounded,
        '완주 카드',
        () => context.push(const CompletionCardPage()),
      ),
      (
        Icons.settings_rounded,
        '앱 설정',
        () => context.push(const SettingsPage()),
      ),
      (Icons.logout_rounded, '로그아웃', _confirmLogout),
    ];

    return AppDetailScaffold(
      title: 'MY',
      trailing: AppIconButton(
        icon: const Icon(Icons.settings_rounded),
        semanticLabel: '설정',
        variant: AppIconButtonVariant.ghost,
        onPressed: () => context.push(const SettingsPage()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: profile.nickname.isEmpty ? '여행' : profile.nickname,
                size: AppAvatarSize.lg,
                ring: true,
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Text(
                  profile.nickname.isEmpty ? '여행자' : profile.nickname,
                  style: AppTextStyle.h3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: '다녀온 곳',
                  value: '${stats.completedCourses}',
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _StatTile(label: '도장', value: '${stats.stamps}'),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _StatTile(label: '리뷰', value: '${stats.reviews}'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              Expanded(
                child: _GradientMenuCard(
                  colors: const [AppColors.green500, AppColors.green400],
                  title: '여행 도장',
                  subtitle:
                      '${stamps.collectedCount}/${stamps.totalCount} 수집',
                  icon: Icons.emoji_events_rounded,
                  onTap: () => context.push(const StampPage()),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _GradientMenuCard(
                  colors: const [AppColors.blue500, AppColors.orange500],
                  title: '숨겨진 여행지',
                  subtitle:
                      '${unlock.unlockedCount}/${unlock.totalCount} 해금',
                  icon: Icons.lock_open_rounded,
                  onTap: () => context.push(const UnlockPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          for (final (icon, label, onTap) in menu)
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: label == '로그아웃'
                          ? AppColors.danger
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyle.body.copyWith(
                          fontWeight: AppFont.semibold,
                          color: label == '로그아웃'
                              ? AppColors.danger
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyle.h3),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyle.small.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _GradientMenuCard extends StatelessWidget {
  const _GradientMenuCard({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final List<Color> colors;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.radiusXl,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXl,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: AppRadius.radiusXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.neutral0,
                      fontWeight: AppFont.extrabold,
                    ),
                  ),
                  Icon(icon, size: 20, color: AppColors.neutral0),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                subtitle,
                style: AppTextStyle.small.copyWith(
                  color: AppColors.neutral0.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
