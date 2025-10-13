class UserSummary {
  final int id;
  final String fullName;
  final String email;

  UserSummary({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }
}