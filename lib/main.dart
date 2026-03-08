// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/wish_list_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/constants/app_colors.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup service locator (async — initializes storage, restores token)
  await setupServiceLocator();

  runApp(const TechHiveApp());
}

class TechHiveApp extends StatelessWidget {
  const TechHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => getIt<ProductProvider>(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => getIt<OrderProvider>(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => getIt<CartProvider>(),
        ),
        ChangeNotifierProvider<WishListProvider>(
          create: (_) => WishListProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => getIt<ChatProvider>(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => getIt<DashboardProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Tech Hive',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorSchemeSeed: AppColors.primary,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5FA),
              cardColor: Colors.white,
              dividerColor: Colors.grey.shade300,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.dark,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey,
                elevation: 12,
              ),
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: AppColors.primary,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              dividerColor: Colors.grey.shade700,
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.grey.shade100,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color(0xFF1E1E1E),
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey.shade500,
                elevation: 12,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}