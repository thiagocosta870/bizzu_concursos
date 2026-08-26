
abstract class IUserPersistenceRepository {
  Future<void> salvarUsuarioNoFirestore(
    String uid,
    String nome,
    String email,
  );
}