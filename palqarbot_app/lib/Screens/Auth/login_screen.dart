
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
import 'package:palqarbot_app/Screens/Auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthController _controller;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // LOGIN
  // ===========================================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _message(
        'Required fields',
        'Please enter your email and password.',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _message(
        'Invalid email',
        'Please enter a valid email address.',
      );
      return;
    }

    final success = await _controller.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      Get.offAllNamed('/bottombar');
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _message(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.r),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            10.h,
            16.w,
            10.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 460.w),
              child: Stack(
                children: [
                  // Background image.
                  Positioned(
                    top: 155.h,
                    left: 0,
                    right: 0,
                    height: 300.h,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/palqarbot.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  // Welcome text and login card.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25.h),

                      const _RobotBadge(),

                      SizedBox(height: 20.h),

                      Text(
                        'Welcome back',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 27.sp,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'Sign in to manage your AI assistant.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),

                      SizedBox(height: 230.h),

                      Expanded(
                        child: GetBuilder<AuthController>(
                          builder: (controller) {
                            return _loginCard(
                              compact: false,
                              loading: controller.isLoading,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LOGIN CARD
  // ===========================================================================

  Widget _loginCard({
    required bool compact,
    required bool loading,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        25.h,
        20.w,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Email'),

          SizedBox(height: 12.h),

          _field(
            controller: _emailController,
            hint: 'Enter your email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 18.h),

          _label('Password'),

          SizedBox(height: 12.h),

          _field(
            controller: _passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffix: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // SIGN IN BUTTON
          SizedBox(height: 30.h),

          SizedBox(
            width: double.infinity,
            height: compact ? 46.h : 50.h,
            child: ElevatedButton(
              onPressed: loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 30.h),

          // REGISTER LINK
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const RegisterScreen());
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD LABEL
  // ===========================================================================

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: 42.h,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autocorrect: !obscureText,
        enableSuggestions: !obscureText,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            size: 18.sp,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40.w,
          ),
          suffixIcon: suffix,
          suffixIconConstraints: BoxConstraints(
            minWidth: 38.w,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 8.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.w,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.4.w,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ROBOT BADGE
// ===========================================================================

class _RobotBadge extends StatelessWidget {
  const _RobotBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE2F0FF),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: AppColors.primary,
        size: 29.sp,
      ),
    );
  }
}
