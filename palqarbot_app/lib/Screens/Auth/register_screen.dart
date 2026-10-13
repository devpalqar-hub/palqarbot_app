
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
import 'package:palqarbot_app/Screens/Auth/login_screen.dart';
import 'package:palqarbot_app/Screens/Onboarding/Views/buisness_descriptionscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _controller = Get.find<AuthController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // REGISTER
  // ===========================================================================

  Future<void> _register() async {
    if (_isRegistering) return;

    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _message('Required fields', 'Please fill in all fields.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _message('Invalid email', 'Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      _message(
        'Weak password',
        'Password must contain at least 8 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      _message('Password mismatch', 'Passwords do not match.');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final parts = name.split(RegExp(r'\s+'));

      final success = await _controller.register(
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (success) {
        Get.offAll(() => const BusinessDescriptionScreen());
      }
    } catch (_) {
      if (!mounted) return;

      _message(
        'Registration failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
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
            20.w,
            10.h,
            20.w,
            8.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 460.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),

                  const _RobotBadge(),

                  SizedBox(height: 10.h),

                  Text(
                    'Create your account',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27.sp,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  Text(
                    'Get started with Palqarbot.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background image behind the registration card.
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 300.h,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/palqarbot.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),

                        // Registration card positioned over the image.
                        Positioned(
                          top: 190.h,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _registerCard(),
                        ),
                      ],
                    ),
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
  // REGISTER CARD
  // ===========================================================================

  Widget _registerCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        20.h,
        16.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16.r),
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
          _label('Full name'),
          SizedBox(height: 10.h),

          _field(
            controller: _nameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
          ),

          SizedBox(height: 15.h),

          _label('Email address'),
          SizedBox(height: 10.h),

          _field(
            controller: _emailController,
            hint: 'Enter your email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 15.h),

          _label('Password'),
          SizedBox(height: 10.h),

          _field(
            controller: _passwordController,
            hint: 'Create a password',
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
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: 15.h),

          _label('Confirm password'),
          SizedBox(height: 10.h),

          _field(
            controller: _confirmPasswordController,
            hint: 'Confirm your password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            suffix: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // CREATE ACCOUNT BUTTON
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: _isRegistering ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isRegistering
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 18.h),

          // SIGN IN LINK
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.off(() => const LoginScreen()),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 10.sp,
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
        fontSize: 11.sp,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: 36.h,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        autocorrect: !obscureText,
        enableSuggestions: !obscureText,
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            size: 17.sp,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 38.w,
          ),
          suffixIcon: suffix,
          suffixIconConstraints: BoxConstraints(
            minWidth: 36.w,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 9.w,
            vertical: 6.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.r),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.w,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.r),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11.r),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.3.w,
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
