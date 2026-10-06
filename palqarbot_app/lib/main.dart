import 'package:flutter/material.dart';
import 'package:palqarbot_app/Screens/Inbox/inboxscreen.dart';
import 'package:palqarbot_app/Screens/Settings/SettingsScreen.dart';
import 'package:palqarbot_app/Screens/bot/BotScreen.dart';
import 'package:palqarbot_app/Screens/leads/LeadsScreen.dart';

import 'package:palqarbot_app/Core/Theme/app_colors.dart';
import 'package:palqarbot_app/Core/Theme/app_textstyles.dart';
import 'package:palqarbot_app/Core/Theme/app_theme.dart';


void main() {
  runApp(const PalqarbotApp());
}

class PalqarbotApp extends StatelessWidget {
  const PalqarbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palqarbot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Inbox',
    'Leads',
    'Bot',
    'Settings',
  ];

  static const List<Widget> _screens = [
    InboxScreen(),
    LeadsScreen(),
    BotScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_selectedIndex],
              style: AppTextStyles.title,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

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

          labelTextStyle: WidgetStateProperty.resolveWith(
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

          iconTheme: WidgetStateProperty.resolveWith(
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

          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.inbox_outlined,
              ),
              selectedIcon: Icon(
                Icons.inbox_rounded,
              ),
              label: 'Inbox',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.people_outline_rounded,
              ),
              selectedIcon: Icon(
                Icons.people_rounded,
              ),
              label: 'Leads',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.auto_awesome_outlined,
              ),
              selectedIcon: Icon(
                Icons.auto_awesome_rounded,
              ),
              label: 'Bot',
            ),

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