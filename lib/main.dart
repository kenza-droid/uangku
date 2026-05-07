import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: const UangkuApp(),
    ),
  );
}

class UangkuApp extends StatefulWidget {
  const UangkuApp({super.key});

  @override
  State<UangkuApp> createState() => _UangkuAppState();
}

class _UangkuAppState extends State<UangkuApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Uangku',
          debugShowCheckedModeBanner: false,
          themeMode: provider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Soft Indigo
              primary: const Color(0xFF6366F1),
              secondary: const Color(0xFF94A3B8),
              tertiary: const Color(0xFF10B981), // Emerald
              error: const Color(0xFFF43F5E), // Rose
              surface: const Color(0xFFF9FAFB),
              onSurface: const Color(0xFF1E293B),
              outlineVariant: const Color(0xFFF1F5F9),
            ),
            textTheme: GoogleFonts.outfitTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E293B),
              elevation: 0,
              centerTitle: false,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              elevation: 8,
              indicatorColor: const Color(0xFF6366F1).withOpacity(0.1),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1));
                }
                return GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8));
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFF6366F1), size: 24);
                }
                return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
              }),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF0F62FE),
              primary: const Color(0xFF78A9FF),
              secondary: const Color(0xFFA8A8A8),
              tertiary: const Color(0xFF24A148),
              error: const Color(0xFFFA4D56),
              surface: const Color(0xFF161616),
              onPrimary: const Color(0xFF161616),
              onSecondary: const Color(0xFF161616),
              onTertiary: const Color(0xFF161616),
              onError: const Color(0xFF161616),
              onSurface: const Color(0xFFF4F4F4),
              outline: const Color(0xFF6F6F6F),
              outlineVariant: const Color(0xFF393939),
              surfaceVariant: const Color(0xFF262626),
            ),
            textTheme: GoogleFonts.ibmPlexSansTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF161616),
              foregroundColor: Color(0xFFF4F4F4),
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: Color(0xFF393939))),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF262626),
              elevation: 0,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF78A9FF));
                }
                return GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFFA8A8A8));
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFF78A9FF), size: 24);
                }
                return const IconThemeData(color: Color(0xFFA8A8A8), size: 24);
              }),
            ),
          ),
          home: _showSplash
              ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
              : const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    AddTransactionScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Riwayat'),
            NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Tambah'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Pengaturan'),
          ],
        ),
      ),
    );
  }
}
