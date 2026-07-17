import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';

class AppSocialLoginButton extends StatelessWidget {
  final String iconPath;
  final String social;
  final void Function() onPressed;

  const AppSocialLoginButton({
    super.key,
    required this.iconPath,
    required this.social,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.neutral0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 20, height: 20),
            SizedBox(width: 8),
            Text(
              '$social로 계속하기',
              style: AppTextStyle.label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
