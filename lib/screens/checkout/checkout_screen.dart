
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pago")),
      body: const Center(
        child: Text("Pantalla de Pago"),
      ),
    );
  }
}
