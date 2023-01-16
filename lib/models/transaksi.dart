class Transaksi {
  int id;
  int idUser;
  int idBisnisKuliner;
  int idNota;
  int jumlahTransaksi;
  String tipeTransaksi;
  String tanggalTransaksi;
  int statusTopup;

  //Constructor
  Transaksi(
      {this.id,
      this.idUser,
      this.idBisnisKuliner,
      this.idNota,
      this.jumlahTransaksi,
      this.tipeTransaksi,
      this.tanggalTransaksi,
      this.statusTopup});

  //Parse Json
  factory Transaksi.fromJson(Map<String, dynamic> object) {
    return Transaksi(
        id: object['id'],
        idUser: object['id_user'],
        idBisnisKuliner: object['id_bisnis_kuliner'],
        idNota: object['id_nota'],
        jumlahTransaksi: object['jumlah_transaksi'],
        tipeTransaksi: object['tipe_transaksi'],
        tanggalTransaksi: object['tanggal_transaksi'],
        statusTopup: object['status_topup']);
  }
}
