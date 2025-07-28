import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/screens/blank_screen.dart';
import 'package:flutter_dashboard_3/screens/contribuicoes_screen.dart';
import 'package:flutter_dashboard_3/screens/membros_list_screen.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/responsive_layout.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/navigation_item_model.dart';
import 'package:flutter_dashboard_3/widgets/layout/sidebar/sidebar.dart';
import 'package:flutter_dashboard_3/widgets/layout/app_bar/custom_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      screen: BlankScreen(title: 'Dashboard'),
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: Colors.blue,
    ),
    NavigationItem(
      screen: MembrosListScreen(),
      title: 'Membros',
      icon: Icons.people_alt,
      color: Color(0xFF00BCD4),
    ),
    NavigationItem(
      screen: ContribuicoesScreen(),
      title: 'Contribuições',
      icon: Icons.payments,
      color: Colors.lightGreen,
    ),
    NavigationItem(
      screen: BlankScreen(title: 'Relatórios'),
      title: 'Relatórios',
      icon: Icons.analytics,
      color: Colors.amber,
    ),
    NavigationItem(
      screen: BlankScreen(title: 'Configurações'),
      title: 'Configurações',
      icon: Icons.settings,
      color: Colors.grey,
    ),
  ];

  NavigationItem get _currentItem => _navigationItems[_selectedIndex];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppTheme.background,
      drawer: Drawer(
        width: 280,
        child: Sidebar(
          navigationItems: _navigationItems,
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemSelected,
          isDrawer: true,
        ),
      ),
      body: Column(
        children: [
          CustomAppBar(
            currentItem: _currentItem,
            showMenuButton: true,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF0F0F0F) : AppTheme.background,
              child: _currentItem.screen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppTheme.background,
      body: Row(
        children: [
          Sidebar(
            navigationItems: _navigationItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
          Expanded(
            child: Column(
              children: [
                CustomAppBar(currentItem: _currentItem),
                Expanded(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF0F0F0F)
                        : AppTheme.background,
                    child: _currentItem.screen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
