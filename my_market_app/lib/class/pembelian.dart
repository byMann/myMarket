class Pembelian {
  int id;
  int produk_id;
  int jumlah;
  double total;
  int pengguna_id;
  String tanggal;

  Pembelian({
    required this.id,
    required this.produk_id,
    required this.jumlah,
    required this.total,
    required this.pengguna_id,
    required this.tanggal,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      id: json['id'] as int,
      produk_id: json['produks_id'] as int,
      jumlah: json['jumlah'],
      total: json['total_harga'],
      pengguna_id: json['penggunas_id'],
      tanggal: json['tanggal_pembelian'],
    );
  }
}
