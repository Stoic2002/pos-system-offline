import 'package:flutter/material.dart';
import '../../core/theme/pixel_colors.dart';
import '../../core/theme/pixel_text_styles.dart';
import '../../features/cashier/cashier_screen.dart';
import '../../features/products/product_list_screen.dart';
import '../../features/reports/reports_screen.dart';
import 'more_menu_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CashierScreen(),
    ProductListScreen(isStandalone: false),
    ReportsScreen(isStandalone: false),
    MoreMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PixelColors.border, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: PixelColors.surface,
          selectedItemColor: PixelColors.primary,
          unselectedItemColor: PixelColors.textMuted,
          selectedLabelStyle: PixelTextStyles.body.copyWith(fontSize: 10),
          unselectedLabelStyle: PixelTextStyles.bodyMuted.copyWith(
            fontSize: 10,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale),
              label: 'KASIR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'PRODUK',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'LAPORAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'LAINNYA',
            ),
          ],
        ),
      ),
    );
  }
}
