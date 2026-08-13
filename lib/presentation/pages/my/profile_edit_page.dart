import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/presentation/controllers/user_controller.dart';

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    return AppDetailScaffold(
      title: '프로필 편집',
      onBack: () => context.pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: '이름', controller: nameController),
          const SizedBox(height: AppSpacing.space4),
          AppTextField(label: '이메일', controller: emailController),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: '저장',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: () {
              userNotifier.updateProfile(
                name: nameController.text.trim().isEmpty
                    ? user.name
                    : nameController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? user.email
                    : emailController.text.trim(),
              );
              AppToast.show(
                context,
                title: '프로필 저장 완료',
                message: '변경한 정보가 저장되었어요.',
                tone: AppToastTone.success,
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
