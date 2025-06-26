class Pesan {
  final int id;
  final int senderId;
  final int receiverId;
  final String konten;
  final int produkId;

  Pesan({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.konten,
    required this.produkId,
  });

  factory Pesan.fromJson(Map<String, dynamic> json) {
    return Pesan(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      konten: json['konten'],
      produkId: json['produks_id'],
    );
  }
}
