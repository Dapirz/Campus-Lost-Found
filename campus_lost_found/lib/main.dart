import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/report_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Campus Lost & Found',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.neutral,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// AuthGate: determines the initial screen based on login status.
/// On first launch, calls init() to check for a stored token.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Initialize auth: check for stored token in SharedPreferences
    Future.microtask(() {
      if (mounted) {
        context.read<AuthProvider>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Still loading (checking token)
        if (!auth.isInitialized) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Campus Lost & Found',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Logged in → HomeScreen
        if (auth.isLoggedIn) {
          return const HomeScreen();
        }

        // Not logged in → LoginScreen
        return const LoginScreen();
      },
    );
  }
}
