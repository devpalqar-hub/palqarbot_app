import 'package:flutter/material.dart';
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

  Get.put(
    AuthController(),
    permanent: true,
  );

  runApp(
    const PalqarbotApp(),
  );
}

class PalqarbotApp extends StatelessWidget {
  const PalqarbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Palqarbot',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      // ========================================================
      // GETX ROUTES
      // ========================================================

      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),

        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
      ],

      // ========================================================
      // INITIAL AUTH CHECK
      // ========================================================

      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _authController;

  late final Future<bool> _authenticationFuture;

  @override
  void initState() {
    super.initState();

    _authController = Get.find<AuthController>();

    // Run authentication check only once.
    _authenticationFuture =
        _authController.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authenticationFuture,

      builder: (context, snapshot) {
        // ======================================================
        // LOADING
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ======================================================
        // AUTHENTICATED
        // ======================================================

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        // ======================================================
        // NOT AUTHENTICATED
        // ======================================================

        return const LoginScreen();
      },
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    InboxScreen(),
    LeadsScreen(),
    BotScreen(),
    SettingsScreen(),
  ];

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

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor:
              AppColors.primaryLight,

          // ====================================================
          // LABEL STYLE
          // ====================================================

          labelTextStyle:
              WidgetStateProperty.resolveWith(
            (states) {
              final selected =
                  states.contains(
                WidgetState.selected,
              );

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

          // ====================================================
          // ICON STYLE
          // ====================================================

          iconTheme:
              WidgetStateProperty.resolveWith(
            (states) {
              final selected =
                  states.contains(
                WidgetState.selected,
              );

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
              NavigationDestinationLabelBehavior
                  .alwaysShow,

          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },

          destinations: const [
            // ==================================================
            // INBOX
            // ==================================================

            NavigationDestination(
              icon: Icon(
                Icons.inbox_outlined,
              ),

              selectedIcon: Icon(
                Icons.inbox_rounded,
              ),

              label: 'Inbox',
            ),

            // ==================================================
            // LEADS
            // ==================================================

            NavigationDestination(
              icon: Icon(
                Icons.people_outline_rounded,
              ),

              selectedIcon: Icon(
                Icons.people_rounded,
              ),

              label: 'Leads',
            ),

            // ==================================================
            // BOT
            // ==================================================

            NavigationDestination(
              icon: Icon(
                Icons.auto_awesome_outlined,
              ),

              selectedIcon: Icon(
                Icons.auto_awesome_rounded,
              ),

              label: 'Bot',
            ),

            // ==================================================
            // SETTINGS
            // ==================================================

            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
              ),

              selectedIcon: Icon(
                Icons.settings_rounded,
              ),

              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}