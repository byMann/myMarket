class Pengguna {
  int id;
  String username;
  String passwordHash;
  String role;

  Pengguna({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      username: json['username'] as String,
      passwordHash: json['password'] as String,
      role: json['role'] as String,
    );
  }
}
