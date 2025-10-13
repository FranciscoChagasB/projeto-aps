class UserAdmin {
  final int id;
  final String fullName;
  final String email;
  bool isActive; // 'bool' e não 'Boolean'
  final DateTime createdAt;
  final List<String> roles;

  UserAdmin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.roles,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      isActive: json['active'],
      createdAt: DateTime.parse(json['createdAt']),
      roles: List<String>.from(json['roles']),
    );
  }
}