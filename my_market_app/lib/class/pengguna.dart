class Pengguna {
  int id;
  String email;
  String passwordHash;
  String role;

  Pengguna({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      email: json['email'] as String,
      passwordHash: json['password'] as String,
      role: json['role'] as String,
    );
  }
}
