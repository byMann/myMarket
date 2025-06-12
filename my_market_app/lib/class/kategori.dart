class Kategori {
  int id;
  String nama;
  List? produk;

  Kategori({
    required this.id,
    required this.nama,
    this.produk,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] as int,
      nama: json['nama'] as String,
      produk: json['produk'],
    );
  }
}
