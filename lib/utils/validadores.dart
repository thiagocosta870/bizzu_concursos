
abstract class Validador {
  String? validar(String? valor);
}

class ValidadorNome implements Validador {
  @override
  String? validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, informe seu nome completo.';
    }
    return null;
  }
}

class ValidadorEmail implements Validador {
  @override
  String? validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, informe seu e-mail.';
    } else if (!valor.contains('@') || !valor.contains('.')) {
      return 'Informe um e-mail válido (ex: seu@email.com).';
    }
    return null;
  }
}

class ValidadorSenha implements Validador {
  @override
  String? validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Por favor, crie uma senha.';
    } else if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }
}