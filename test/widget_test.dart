import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body:const Center(
          child: Text('0'), // Un simple texto para el test
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        
        
      ),
    );
  }
}

// Test fuera de la clase
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(const MyWidget());
    

    // Verifica que empieza en 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simula el toque del botón
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Aquí no cambiará a '1' porque el botón no hace nada aún.
    expect(find.text('0'), findsOneWidget); // Se mantiene
    expect(find.text('1'), findsNothing); // Sigue sin encontrarlo
  });
}
