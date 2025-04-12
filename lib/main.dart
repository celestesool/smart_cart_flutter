import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'providers/cart_provider.dart';
import 'providers/guest_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const SmartCartApp(),
    ),
  );
}

class SmartCartApp extends StatelessWidget {
  const SmartCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    
      initialRoute: '/welcome',

      routes: appRoutes,
    );
  }
}
