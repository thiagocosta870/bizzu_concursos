import '../usuario_model.dart';

abstract class IAuthenticationRepository {
  Future<String> cadastrarUsuarioComEmail(UsuarioModel usuario);
}