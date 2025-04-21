//  lib/utils/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/voice_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/calificar_screen.dart';
import '../screens/recibo_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String catalog = '/catalog';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String voice = '/voice';
  static const String welcome = '/welcome';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.voice: (context) => const VoiceScreen(),
  AppRoutes.catalog: (context) => const CatalogoScreen(),
  AppRoutes.cart: (context) => const CartScreen(),
  AppRoutes.checkout: (context) => const CheckoutScreen(),
  AppRoutes.welcome: (context) => const WelcomeScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  '/voz': (context) => const VoiceScreen(),
  AppRoutes.home: (context) => const WelcomeScreen(),

  //  Ruta para recibo
  '/recibo': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ReciboScreen(idCompra: args['id_compra']);
  },

  //  Ruta para calificación
  '/calificar': (context) => const CalificarScreen(),
};
