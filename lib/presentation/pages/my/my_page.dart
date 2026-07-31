import 'package:flutter/material.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/radius.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/mock/eodiganam_data.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/pages/auth/login_page.dart';
import 'package:mople_mobile/presentation/pages/destination/review_page.dart';
import 'package:mople_mobile/presentation/pages/my/settings_page.dart';
import 'package:mople_mobile/presentation/pages/my/stamp_page.dart';
import 'package:mople_mobile/presentation/pages/my/unlock_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key, required this.onSwitchTab});

  final ValueChanged<String> onSwitchTab;

  void _confirmLogout(BuildContext context) {
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
    final user = EodiganamData.user;
    final earnedStamps = EodiganamData.stamps.where((s) => s.earned).length;
    final unlockedCourses = EodiganamData.unlockCourses
        .where(
          (c) => c.requiredWeather == EodiganamData.currentWeatherCondition,
        )
        .length;

    final menu = <(IconData, String, VoidCallback)>[
      (Icons.edit_rounded, '프로필 편집', () {}),
      (Icons.map_rounded, '내 여행 기록', () => onSwitchTab('bookmark')),
      (
        Icons.star_rounded,
        '내가 쓴 리뷰',
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReviewPage())),
      ),
      (Icons.favorite_rounded, '찜한 여행지', () => onSwitchTab('bookmark')),
      (
        Icons.settings_rounded,
        '앱 설정',
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
      ),
      (Icons.logout_rounded, '로그아웃', () => _confirmLogout(context)),
    ];

    return AppDetailScaffold(
      title: 'MY',
      trailing: AppIconButton(
        icon: const Icon(Icons.settings_rounded),
        semanticLabel: '설정',
        variant: AppIconButtonVariant.ghost,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppAvatar(name: '여행', size: AppAvatarSize.lg, ring: true),
              const SizedBox(width: AppSpacing.space4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name, style: AppTextStyle.h3),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space2,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fillBrandSoft,
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Text(
                      '🏅 ${user.level}',
                      style: AppTextStyle.small.copyWith(
                        color: AppColors.textBrand,
                        fontWeight: AppFont.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: _StatTile(label: '다녀온 곳', value: '${user.trips}'),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _StatTile(label: '도장', value: '${user.stamps}'),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _StatTile(label: '리뷰', value: '${user.reviews}'),
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
                  subtitle: '$earnedStamps/${EodiganamData.stamps.length} 수집',
                  icon: Icons.emoji_events_rounded,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const StampPage())),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _GradientMenuCard(
                  colors: const [AppColors.blue500, AppColors.orange500],
                  title: '숨겨진 여행지',
                  subtitle:
                      '$unlockedCourses/${EodiganamData.unlockCourses.length} 해금',
                  icon: Icons.lock_open_rounded,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const UnlockPage())),
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
