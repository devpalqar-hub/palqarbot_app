import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';

import 'package:palqarbot_app/Screens/Auth/login_screen.dart';
import 'package:palqarbot_app/main.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  late final AuthController _controller;

  final TextEditingController
      _firstNameController =
      TextEditingController();

  final TextEditingController
      _lastNameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _controller =
        Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : Get.put(AuthController());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final firstName =
        _firstNameController.text.trim();

    final lastName =
        _lastNameController.text.trim();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      return;
    }

    final success =
        await _controller.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Get.offAll(
        () => const HomeScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              AppColors.background,
          appBar: AppBar(
            backgroundColor:
                AppColors.background,
            elevation: 0,
            leading: IconButton(
              onPressed: () =>
                  Get.back(),
              icon: Icon(
                Icons.arrow_back,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(
                24,
                10,
                24,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 420,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Create account',
                        style:
                            AppTextStyles.title
                                .copyWith(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Create your Palqarbot account to get started.',
                        style:
                            AppTextStyles.body
                                .copyWith(
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      _buildRegisterCard(
                        controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterCard(
    AuthController controller,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildLabel('First name'),
          const SizedBox(height: 8),
          _buildField(
            controller:
                _firstNameController,
            hint: 'Enter first name',
          ),

          const SizedBox(height: 16),

          _buildLabel('Last name'),
          const SizedBox(height: 8),
          _buildField(
            controller:
                _lastNameController,
            hint: 'Enter last name',
          ),

          const SizedBox(height: 16),

          _buildLabel('Email'),
          const SizedBox(height: 8),
          _buildField(
            controller:
                _emailController,
            hint: 'Enter your email',
            keyboardType:
                TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          _buildLabel('Password'),
          const SizedBox(height: 8),
          _buildField(
            controller:
                _passwordController,
            hint: 'Create a password',
            obscureText:
                _obscurePassword,
            suffixIcon:
                IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword =
                      !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons
                        .visibility_outlined
                    : Icons
                        .visibility_off_outlined,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading
                      ? null
                      : _register,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.textWhite,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
              ),
              child:
                  controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          'Create account',
                          style:
                              AppTextStyles
                                  .button
                                  .copyWith(
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: AppTextStyles
                    .bodySmall
                    .copyWith(
                  color:
                      AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.off(
                    () =>
                        const LoginScreen(),
                  );
                },
                child: Text(
                  'Sign in',
                  style: AppTextStyles
                      .bodySmall
                      .copyWith(
                    color:
                        AppColors.primary,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style:
          AppTextStyles.bodySmall.copyWith(
        fontWeight:
            FontWeight.w600,
        color:
            AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController
        controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style:
          AppTextStyles.body.copyWith(
        fontSize: 14,
        color:
            AppColors.textPrimary,
      ),
      decoration:
          InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodySmall
                .copyWith(
          color:
              AppColors.textSecondary,
        ),
        suffixIcon:
            suffixIcon,
        filled: true,
        fillColor:
            AppColors.background,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: BorderSide(
            color:
                AppColors.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: BorderSide(
            color:
                AppColors.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: BorderSide(
            color:
                AppColors.primary,
          ),
        ),
      ),
    );
  }
}