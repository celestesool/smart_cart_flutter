
import 'package:flutter/material.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Venta por Voz")),
      body: const Center(
        child: Text("Pantalla de Venta por Voz"),
      ),
    );
  }
}
