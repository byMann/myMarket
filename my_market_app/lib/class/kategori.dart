class Kategori {
  int id;
  String nama;
  String gambar;

  List? produk;

  Kategori({required this.id, required this.nama, required this.gambar, this.produk});

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] as int,
      nama: json['nama'] as String,
      gambar: json['gambar'] as String,
      produk: json['produk'],
    );
  }
}
