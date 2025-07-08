class Pembelian {
  int id;
  int produk_id;
  int jumlah;
  int total;
  int pengguna_id;
  String tanggal;
  String? order_id;
  String? snap_token;
  String? status;
  String? payment_type;

  Pembelian({
    required this.id,
    required this.produk_id,
    required this.jumlah,
    required this.total,
    required this.pengguna_id,
    required this.tanggal,
    this.order_id,
    this.snap_token,
    this.status,
    this.payment_type,
  });

  factory Pembelian.fromJson(Map<String, dynamic> json) {
    return Pembelian(
      id: json['id'] as int,
      produk_id: json['produks_id'] as int,
      jumlah: json['jumlah'] as int,
      total: json['total_harga'],
      pengguna_id: json['penggunas_id'] as int,
      tanggal: json['tanggal_pembelian'],
      order_id: json['order_id'] ?? null,
      snap_token: json['snap_token'] ?? null,
      status: json['status'] ?? null,
      payment_type: json['payment_type'] ?? null,
    );
  }
}
