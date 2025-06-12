class Pesan {
  int id;
  int sender_id;
  int receiver_id;
  String konten;
  String gambar;
  int produk_id;

  Pesan({
    required this.id,
    required this.sender_id,
    required this.receiver_id,
    required this.konten,
    required this.gambar,
    required this.produk_id,
  });

  factory Pesan.fromJson(Map<String, dynamic> json) {
    return Pesan(
      sender_id: json['id_pesans'] as int,
      receiver_id: json['receiver_id'] as int,
      id: json['id_pesans'],
      konten: json['konten'],
      gambar: json['gambar'],
      produk_id: json['produks_id'],
    );
  }
}
