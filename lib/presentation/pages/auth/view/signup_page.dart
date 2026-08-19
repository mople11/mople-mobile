import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/navigation/app_navigation.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/core/constants/spacing.dart';
import 'package:mople_mobile/core/widgets/widgets.dart';
import 'package:mople_mobile/data/models/models.dart';
import 'package:mople_mobile/presentation/controllers/auth_controller.dart';
import 'package:mople_mobile/presentation/controllers/base/async_result.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();
  final _codeController = TextEditingController();

  bool _agree = false;
  bool _done = false;
  bool _submitting = false;

  /// 아이디 중복확인을 **통과한** 값. 제출 전 재확인을 강제하는 데 쓴다.
  String? _checkedId;

  /// 성공·실패와 무관하게 **마지막으로 검사한** 값.
  ///
  /// 실패 시에는 [_checkedId] 가 채워지지 않으므로, 입력이 바뀌었는지 판단하려면
  /// 이 값을 봐야 한다. 이게 없으면 중복 판정을 받은 뒤 아이디를 고쳐도
  /// 이전 오류 문구가 새 아이디에 그대로 남는다.
  String? _lastCheckedId;

  /// 인증 확인을 통과한 코드. 회원가입 요청의 `verifyCode` 로 그대로 쓴다.
  String? _verifiedCode;

  @override
  void dispose() {
    _idController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  AuthState get _auth => ref.watch(authProvider);

  AuthNotifier get _notifier => ref.read(authProvider.notifier);

  /// 아이디가 바뀌면 이전 검사 결과를 무효로 돌린다.
  void _onIdChanged(String value) {
    final changed = value.trim() != _lastCheckedId;
    if (changed && _lastCheckedId != null) {
      _notifier.resetIdCheck();
      _checkedId = null;
      _lastCheckedId = null;
    }
    setState(() {});
  }

  Future<void> _checkId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '아이디를 입력해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }
    await _notifier.checkId(id);
    if (!mounted) return;
    setState(() => _lastCheckedId = id);

    final result = ref.read(authProvider).idAvailable;
    // 통신 자체가 실패하면 available 이 null 이라 화면에 아무 변화가 없다.
    // 사용자가 버튼이 먹통이라고 느끼지 않도록 에러를 그대로 띄운다.
    if (result?.hasError ?? false) {
      AppToast.show(
        context,
        title: '확인 실패',
        message: result!.apiError?.displayMessage ?? '아이디를 확인하지 못했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }
    if (result?.value == true) setState(() => _checkedId = id);
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '이메일을 정확히 입력해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }
    final ok = await _notifier.sendEmailCode(email);
    if (!mounted) return;
    if (ok) {
      AppToast.show(
        context,
        title: '인증번호 발송',
        message: '입력하신 이메일로 인증번호를 보냈어요.',
        tone: AppToastTone.success,
      );
    } else {
      final error = ref.read(authProvider).emailCodeSend?.apiError;
      AppToast.show(
        context,
        title: '발송 실패',
        message: error?.displayMessage ?? '인증번호 발송에 실패했어요.',
        tone: AppToastTone.danger,
      );
    }
  }

  Future<void> _confirmEmailCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    final ok = await _notifier.confirmEmailCode(email: email, code: code);
    if (!mounted) return;
    if (ok) {
      setState(() => _verifiedCode = code);
    } else {
      final error = ref.read(authProvider).emailCodeConfirm?.apiError;
      AppToast.show(
        context,
        title: '인증 실패',
        message: error?.displayMessage ?? '인증번호가 일치하지 않아요.',
        tone: AppToastTone.danger,
      );
    }
  }

  Future<void> _submit() async {
    final id = _idController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final pw = _pwController.text;
    final pwCheck = _pwCheckController.text;

    if (_checkedId != id) {
      AppToast.show(
        context,
        title: '아이디 확인 필요',
        message: '아이디 중복확인을 먼저 진행해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }
    if (_verifiedCode == null) {
      AppToast.show(
        context,
        title: '이메일 인증 필요',
        message: '이메일 인증을 먼저 완료해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }
    if (nickname.isEmpty || pw.length < 8 || pw != pwCheck || !_agree) {
      AppToast.show(
        context,
        title: '입력 확인',
        message: '입력하신 내용을 다시 확인해주세요.',
        tone: AppToastTone.warning,
      );
      return;
    }

    setState(() => _submitting = true);
    await _notifier.submitSignup(
      SignupRequest(
        id: id,
        pw: pw,
        pwCheck: pwCheck,
        nickname: nickname,
        email: email,
        verifyCode: _verifiedCode!,
        agreeTerms: _agree,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    final signup = ref.read(authProvider).signup;
    if (signup?.hasError ?? false) {
      AppToast.show(
        context,
        title: '회원가입 실패',
        message: signup!.apiError?.displayMessage ?? '회원가입에 실패했어요.',
        tone: AppToastTone.danger,
      );
      return;
    }
    // 세대가 어긋나 결과가 반영되지 않았으면 완료 화면으로 넘기지 않는다.
    if (signup?.value == null) return;
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: '회원가입',
      onBack: () => context.pop(),
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      body: _done ? _buildDone() : _buildForm(),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successBg,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 34,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          Text(
            '회원가입이 완료됐어요',
            style: AppTextStyle.bodyLg.copyWith(fontWeight: AppFont.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '어디가남과 함께 전남을 여행해보세요.',
            style: AppTextStyle.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space6),
          AppButton(
            label: '로그인하기',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final auth = _auth;
    final idChecking = auth.idAvailable is AsyncLoading;
    final idAvailable = auth.idAvailable?.value;
    // 성공/실패 어느 쪽이든 "검사한 값"과 지금 입력이 다르면 결과는 무효다.
    final idChanged =
        _lastCheckedId != null && _lastCheckedId != _idController.text.trim();
    final emailSending = auth.emailCodeSend is AsyncLoading;
    final emailConfirming = auth.emailCodeConfirm is AsyncLoading;
    final codeSent = auth.emailCodeSent && _verifiedCode == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어디가남 계정을 만들어 나만의 전남 여행을 기록해보세요.',
            style: AppTextStyle.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppTextField.asciiOnly(
            label: '아이디',
            placeholder: '영문/숫자 4자 이상',
            controller: _idController,
            onChanged: _onIdChanged,
            // 아이디를 고치면 이전 검사 결과는 더 이상 이 값에 대한 판정이
            // 아니므로 문구를 지운다(_onIdChanged 가 상태도 함께 비운다).
            errorText: (idAvailable == false && !idChanged)
                ? '이미 사용 중인 아이디예요.'
                : null,
            suffixIcon: AppButton(
              label: idChecking ? '확인 중' : '중복확인',
              variant: AppButtonVariant.link,
              size: AppButtonSize.sm,
              onPressed: idChecking ? null : _checkId,
            ),
          ),
          if (idAvailable == true && !idChanged) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(
              '사용 가능한 아이디예요.',
              style: AppTextStyle.caption.copyWith(color: AppColors.success),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          AppTextField(
            label: '닉네임',
            placeholder: '사용하실 닉네임을 입력해주세요',
            controller: _nicknameController,
          ),
          const SizedBox(height: AppSpacing.space4),
          AppTextField.asciiOnly(
            label: '이메일',
            placeholder: 'you@example.com',
            controller: _emailController,
            enabled: _verifiedCode == null,
            onChanged: (_) => setState(() {}),
            pattern: r'[a-zA-Z0-9@._+-]',
            suffixIcon: AppButton(
              label: _verifiedCode != null
                  ? '인증완료'
                  : (auth.emailCodeSent ? '재발송' : '인증번호 발송'),
              variant: AppButtonVariant.link,
              size: AppButtonSize.sm,
              onPressed: (emailSending || _verifiedCode != null)
                  ? null
                  : _sendEmailCode,
            ),
          ),
          if (codeSent) ...[
            const SizedBox(height: AppSpacing.space3),
            AppTextField(
              label: '인증번호',
              placeholder: '6자리 숫자를 입력해주세요',
              controller: _codeController,
              suffixIcon: AppButton(
                label: emailConfirming ? '확인 중' : '인증확인',
                variant: AppButtonVariant.link,
                size: AppButtonSize.sm,
                onPressed: emailConfirming ? null : _confirmEmailCode,
              ),
            ),
          ],
          if (_verifiedCode != null) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(
              '이메일 인증이 완료됐어요.',
              style: AppTextStyle.caption.copyWith(color: AppColors.success),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          AppPasswordField(
            label: '비밀번호',
            placeholder: '8자 이상 입력해주세요',
            controller: _pwController,
          ),
          const SizedBox(height: AppSpacing.space4),
          AppPasswordField(
            label: '비밀번호 확인',
            placeholder: '비밀번호를 다시 입력해주세요',
            controller: _pwCheckController,
          ),
          const SizedBox(height: AppSpacing.space5),
          AppCheckbox(
            label: '이용약관 및 개인정보처리방침에 동의합니다',
            value: _agree,
            onChanged: (v) => setState(() => _agree = v),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            label: _submitting ? '가입 중...' : '가입하기',
            width: double.infinity,
            size: AppButtonSize.lg,
            onPressed: (_agree && !_submitting) ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '이미 계정이 있으신가요? ',
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              AppTextLink(label: '로그인', onTap: () => context.pop()),
            ],
          ),
        ],
      ),
    );
  }
}
