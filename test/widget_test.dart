import 'package:flutter_test/flutter_test.dart';
import 'package:bizzu_concursos/main.dart';

void main() {
  testWidgets('Teste de inicialização do app', (WidgetTester tester) async {
    
    await tester.pumpWidget(const BizzuApp());

    
    expect(find.text('Bem-vindo ao\nBizzu Concursos'), findsOneWidget);
  });
}