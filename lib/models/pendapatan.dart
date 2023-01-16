class Pendapatan {
  int id;
  int idBisnisKuliner;
  int idNota;
  int totalHarga;
  int komisi;
  int pendapatanBersih;
  String tanggalPendapatan;

  //Constructor
  Pendapatan(
      {this.id,
      this.idBisnisKuliner,
      this.idNota,
      this.totalHarga,
      this.komisi,
      this.pendapatanBersih,
      this.tanggalPendapatan});

  //Parse Json
  factory Pendapatan.fromJson(Map<String, dynamic> object) {
    return Pendapatan(
        id: object['id'],
        idBisnisKuliner: object['id_bisnis_kuliner'],
        idNota: object['id_nota'],
        totalHarga: object['total_harga'],
        komisi: object['komisi'],
        pendapatanBersih: object['pendapatan_bersih'],
        tanggalPendapatan: object['tanggal_pendapatan']);
  }
}
