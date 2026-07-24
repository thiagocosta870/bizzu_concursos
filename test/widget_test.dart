import 'package:flutter_test/flutter_test.dart';
import 'package:bizzu_concursos/main.dart';

void main() {
  testWidgets('Teste de inicialização do app', (WidgetTester tester) async {
    // Constrói o nosso app com o nome correto
    await tester.pumpWidget(const BizzuApp());

    // Verifica se o texto de boas-vindas aparece na tela para confirmar que rodou
    expect(find.text('Bem-vindo ao\nBizzu Concursos'), findsOneWidget);
  });
}