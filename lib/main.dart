import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: const UangkuApp(),
    ),
  );
}

class UangkuApp extends StatelessWidget {
  const UangkuApp({super.key});

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
              seedColor: const Color(0xFF0F62FE),
              primary: const Color(0xFF0F62FE),
              secondary: const Color(0xFF6F6F6F),
              tertiary: const Color(0xFF198038),
              error: const Color(0xFFDA1E28),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onTertiary: Colors.white,
              onError: Colors.white,
              onSurface: const Color(0xFF161616),
              outline: const Color(0xFF8D8D8D),
              outlineVariant: const Color(0xFFE0E0E0),
              surfaceVariant: const Color(0xFFF4F4F4),
            ),
            textTheme: GoogleFonts.ibmPlexSansTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF161616),
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFFF8F9FA),
              elevation: 0,
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F62FE));
                }
                return GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF6F6F6F));
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Color(0xFF0F62FE), size: 24);
                }
                return const IconThemeData(color: Color(0xFF6F6F6F), size: 24);
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
          home: const MainNavigationShell(),
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
      body: _screens[_selectedIndex],
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
