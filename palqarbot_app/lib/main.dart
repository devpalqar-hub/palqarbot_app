
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_theme.dart';

import 'package:palqarbot_app/Screens/Auth/Service/auth_controller.dart';
import 'package:palqarbot_app/Screens/Auth/login_screen.dart';

import 'package:palqarbot_app/Screens/Inbox/inboxscreen.dart';
import 'package:palqarbot_app/Screens/Settings/SettingsScreen.dart';
import 'package:palqarbot_app/Screens/bot/BotScreen.dart';
import 'package:palqarbot_app/Screens/leads/LeadsScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put<AuthController>(
    AuthController(),
    permanent: true,
  );

  runApp(const PalqarbotApp());
}

class PalqarbotApp extends StatelessWidget {
  const PalqarbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Palqarbot',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          getPages: [
            GetPage(
              name: '/login',
              page: () => const LoginScreen(),
            ),
            GetPage(
              name: '/bottombar',
              page: () => const Bottombar(),
            ),
          ],
          home: const AuthGate(),
        );
      },
    );
  }
}

// AUTH GATE + SPLASH SCREEN

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _authenticationFuture;

  @override
  void initState() {
    super.initState();

    _authenticationFuture =
        Get.find<AuthController>().isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authenticationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to check login status.'),
            ),
          );
        }

        if (snapshot.data == true) {
          return const Bottombar();
        }

        return const LoginScreen();
      },
    );
  }
}

// SPLASH SCREEN

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Robot illustration
              Container(
                width: 190.w,
                height: 190.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(15.w),
                child: Image.asset(
                  'assets/robo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.smart_toy_rounded,
                      size: 100.sp,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),

              SizedBox(height: 28.h),

              // App name
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Palqar',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'bot',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Tagline
              Text(
                'Your AI Assistant for Business',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 38.h),

              // Loading indicator
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BOTTOM NAVIGATION

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const InboxScreen(),
      const LeadsScreen(),
      const BotScreen(),
      const SettingsScreen(),
    ];
  }

  void _navigateToTab(int index) {
    if (index < 0 || index >= _screens.length) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 820,
            ),
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.primaryLight,
          labelTextStyle:
              WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              final selected =
                  states.contains(WidgetState.selected);

              return TextStyle(
                color: selected
                    ? AppColors.primary
                    : Colors.grey,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
              );
            },
          ),
          iconTheme:
              WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              final selected =
                  states.contains(WidgetState.selected);

              return IconThemeData(
                color: selected
                    ? AppColors.primary
                    : Colors.grey,
                size: 24,
              );
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _navigateToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox_rounded),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Leads',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Bot',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
