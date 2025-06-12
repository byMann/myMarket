class Produk {
  int id;
  String nama;
  String deskripsi;
  double harga;
  int stok;
  String gambar;
  List? kategori;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.gambar,
    this.kategori,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['product_id'] as int,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: json['harga'] != null ? json['harga'] : '0.0',
      stok: json['stok'] != null ? json['stok'] : '0',
      gambar: json['image'] as String,
      kategori: json['kategori'],
    );
  }
}
