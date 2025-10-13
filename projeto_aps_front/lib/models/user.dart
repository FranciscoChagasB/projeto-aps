class User {
  final String email;
  final String fullName;
  final String role;
  final String professionalCode;

  User({
    required this.email,
    required this.fullName,
    required this.role,
    required this.professionalCode,
  });

  /// Factory constructor para criar um User a partir do payload de um token JWT.
  factory User.fromJson(Map<String, dynamic> json) {
    // MUDANÇA AQUI: Tratamos 'roles' como uma lista de Strings, não de objetos.
    // Pegamos o primeiro item da lista, que já é a String da role.
    String rawRole = (json['roles'] as List).isNotEmpty
        ? (json['roles'] as List).first as String
        : 'UNKNOWN';

    // Remove o prefixo 'ROLE_' para termos um nome limpo.
    String finalRole = rawRole.startsWith('ROLE_') ? rawRole.substring(5) : rawRole;

    return User(
      email: json['sub'],
      fullName: json['fullName'],
      role: finalRole,
      professionalCode: json['professionalCode'] ?? '', // Adicionado para o terapeuta
    );
  }
}