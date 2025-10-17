class UserAdmin {
  final int id;
  final String fullName;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final List<String> roles;
  final String? cpf;
  final String? phone;
  final String? professionalCode;

  UserAdmin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.roles,
    this.cpf,
    this.phone,
    this.professionalCode,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    final rolesList = (json['roles'] as List? ?? [])
        .map((roleJson) => roleJson['name'] as String)
        .toList();

    return UserAdmin(
      id: json['id'],
      fullName: json['fullName'] ?? '', // Fallback para string vazia
      email: json['email'] ?? '',
      isActive: json['active'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      roles: rolesList,
      cpf: json['cpf'],
      phone: json['phone'],
      professionalCode: json['professionalCode'],
    );
  }
}