import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/app_state.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/dashboard/user_dashboard.dart';
import '../../features/tracker/tracker_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/qr/qr_scanner_screen.dart';
import '../../features/admin/admin_screens.dart';

// --- USER SHELL WRAPPER ---
// Standard Bottom Navigation Bar that manages sub-views locally to preserve state
class UserShellScreen extends StatefulWidget {
  const UserShellScreen({super.key});

  @override
  State<UserShellScreen> createState() => _UserShellScreenState();
}

class _UserShellScreenState extends State<UserShellScreen> {
  int _currentIndex = 2; // Default is Dashboard (Center - index 2)
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TrackerScreen(),
      const MapScreen(),
      UserDashboardScreen(onTabChange: (index) {
        if (!mounted) return;
        setState(() {
          _currentIndex = index;
        });
      }),
      const QRScannerScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code),
            label: 'Escáner QR',
          ),
        ],
      ),
    );
  }
}

class AppRouter {
  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: appState,
      redirect: (context, state) {
        final isLoggedIn = appState.isLoggedIn;
        final isAdmin = appState.isAdmin;
        final goingToAuth = state.matchedLocation == '/splash' ||
            state.matchedLocation == '/welcome' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isLoggedIn) {
          // If not logged in and not going to auth, send to welcome
          if (!goingToAuth) {
            return '/welcome';
          }
          return null;
        }

        // If logged in
        if (goingToAuth) {
          return isAdmin ? '/admin' : '/user';
        }

        // Check permissions
        if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
          return '/user';
        }
        if (state.matchedLocation.startsWith('/user') && isAdmin) {
          return '/admin';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserShellScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminShellScreen(),
        ),
      ],
    );
  }
}
