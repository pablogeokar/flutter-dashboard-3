import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/screens/blank_screen.dart';
import 'package:flutter_dashboard_3/theme.dart';
import 'package:flutter_dashboard_3/responsive_layout.dart';

// Classe para encapsular dados de navegação
class NavigationItem {
  final Widget screen;
  final String title;
  final IconData icon;
  final Color color;

  const NavigationItem({
    required this.screen,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainLayout> {
  int _selectedIndex = 0;
  final String _appVersion = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados dos itens de navegação centralizados
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      screen: BlankScreen(title: 'Dashboard'),
      title: 'Dashboard',
      icon: Icons.dashboard,
      color: Colors.blue,
    ),
    NavigationItem(
      screen: BlankScreen(title: 'Membros'),
      title: 'Membros',
      icon: Icons.people_alt,
      color: Color(0xFF00BCD4),
    ),
    NavigationItem(
      screen: BlankScreen(title: 'Contribuições'),
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

  @override
  void initState() {
    super.initState();
    //_loadAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  // Layout para mobile com drawer
  Widget _buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppTheme.background,
      drawer: Drawer(width: 280, child: _buildSidebarContent()),
      body: Column(
        children: [
          _buildAppBar(showMenuButton: true),
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

  // Layout para desktop com sidebar fixa
  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppTheme.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(showMenuButton: false),
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

  // Sidebar para desktop
  Widget _buildSidebar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        // Sidebar com fundo branco puro no modo claro
        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.sidebarBackground,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : AppTheme.navBorder,
            width: 1.5, // Borda mais visível
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AppTheme.sidebarShadow.withValues(
                    alpha: 0.12,
                  ), // Sombra mais forte
            blurRadius: isDark ? 12 : 20,
            offset: const Offset(3, 0),
            spreadRadius: isDark ? 0 : 2,
          ),
        ],
      ),
      child: _buildSidebarContent(),
    );
  }

  // Conteúdo da sidebar (reutilizado no drawer)
  Widget _buildSidebarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebarHeader(),
        _buildDivider(),
        const SizedBox(height: 24),
        _buildNavigationMenu(),
        _buildUserInfo(),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Header com gradiente azul
        //gradient: isDark ? null : AppTheme.sidebarHeaderGradient,
        color: isDark ? const Color(0xFF2A2A2A) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/logo-loja.png',
              height: 128, // Reduzido para melhor proporção
              width: 128,
            ),
          ),
          _buildCompanyInfo(),
          if (_appVersion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _appVersion,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.divider.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
        color: isDark ? AppTheme.dividerDark.withValues(alpha: 0.3) : null,
      ),
    );
  }

  Widget _buildNavigationMenu() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _navigationItems.length,
        itemBuilder: (context, index) => _buildNavItem(index),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() => _selectedIndex = index);
            if (ResponsiveLayout.isMobile(context)) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                        ? item.color.withValues(alpha: 0.15)
                        : AppTheme.primary.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: isDark
                          ? item.color.withValues(alpha: 0.3)
                          : AppTheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
              boxShadow: isSelected && !isDark
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? item.color.withValues(alpha: 0.2)
                              : AppTheme.primary.withValues(alpha: 0.12))
                        : (isDark
                              ? Colors.transparent
                              : AppTheme.surface.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? (isDark ? item.color : AppTheme.primary)
                        : (isDark ? Colors.grey[400] : AppTheme.textSecondary),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppTheme.textOnDark : AppTheme.primary)
                        : (isDark ? Colors.grey[300] : AppTheme.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? item.color : AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? item.color : AppTheme.primary)
                              .withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : AppTheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withValues(alpha: 0.2)
              : AppTheme.navBorder.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isDark ? null : AppTheme.primaryGradient,
              color: isDark ? Colors.grey[700] : null,
              borderRadius: BorderRadius.circular(22),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: isDark ? Colors.grey[400] : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antonio Neto',
                  style: TextStyle(
                    color: isDark ? AppTheme.textOnDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Tesoureiro',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[500] : AppTheme.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar({bool showMenuButton = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        //color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : AppTheme.navBorder.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120, // Reduzido para melhor proporção
                width: 120,
              ),
              if (showMenuButton) ...[
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? AppTheme.textOnDark : AppTheme.primary,
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              _buildAppBarTitle(),
            ],
          ),
          _buildAppBarActions(),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? _currentItem.color.withValues(alpha: 0.2)
                : AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _currentItem.icon,
            color: isDark ? _currentItem.color : AppTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _currentItem.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textOnDark : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarActions() {
    return Row(children: [..._buildActionButtons()]);
  }

  Widget _buildCompanyInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Harmonia, Luz e Sigilo nº 46',
          style: TextStyle(
            color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'CNPJ: 12.345.678/0001-90',
          style: TextStyle(
            color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      _buildActionButton(Icons.search, () {}),
      const SizedBox(width: 8),
      _buildNotificationButton(),
      const SizedBox(width: 8),
      _buildActionButton(Icons.fullscreen, () {}),
    ];
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.transparent
              : AppTheme.navBorder.withValues(alpha: 0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
        iconSize: 20,
      ),
    );
  }

  Widget _buildNotificationButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.transparent : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.transparent
                  : AppTheme.navBorder.withValues(alpha: 0.3),
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: isDark ? Colors.grey[600] : AppTheme.textSecondary,
            iconSize: 20,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
