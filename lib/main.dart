import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

import 'utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //final prefs = await SharedPreferences.getInstance();
  //await prefs.remove('token'); // ✅ Borra el token al iniciar (solo para prueba)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void limpiarDatosGuardados() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("🧹 Preferencias limpiadas");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> verificarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUsuario = prefs.getInt('id_usuario');
    return token != null && idUsuario != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cart',
      debugShowCheckedModeBanner: false,
      //initialRoute: '/voz', // o donde inicie
      routes: appRoutes, // <- usa tu mapa aquí
      // routes: {
      //  '/': (context) => const WelcomeScreen(),
      //   '/catalogo': (context) => const CatalogoScreen(),
      //    '/cart': (context) => const CartScreen(),
      //   '/checkout': (context) => const CheckoutScreen(),
      //  },
      // routes: appRoutes,
      //initialRoute: AppRoutes.welcome,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        primaryColor: const Color(0xFF43A047),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF43A047),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
