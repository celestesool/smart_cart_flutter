
import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/voice_sale/voice_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/welcome/welcome_screen.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/catalog': (context) => const CatalogScreen(),
  '/cart': (context) => const CartScreen(),
  '/checkout': (context) => const CheckoutScreen(),
  '/voice': (context) => const VoiceScreen(),
  '/welcome': (context) => const WelcomeScreen(),
  

};
