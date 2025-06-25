class Produk {
  int id;
  String nama;
  String deskripsi;
  int harga;
  int stok;
  String nama_penjual;
  List? kategori;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.nama_penjual,
    this.kategori,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      nama_penjual: json['nama_penjual'] ?? '',
      kategori: json['kategoris'] ?? [],
    );
  }
}
