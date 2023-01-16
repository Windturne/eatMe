class Orders {
  int id;
  int idUser;
  int idBisnisKuliner;
  int idMenu;
  int idDetailBundle;
  int idNota;
  int jumlahMakanan;
  String catatanMakanan;
  String tanggalPemesanan;
  int statusOrder;
  String keteranganOrder;

  //Constructor
  Orders(
      {this.id,
      this.idUser,
      this.idBisnisKuliner,
      this.idMenu,
      this.idDetailBundle,
      this.idNota,
      this.jumlahMakanan,
      this.catatanMakanan,
      this.tanggalPemesanan,
      this.statusOrder,
      this.keteranganOrder});

  //Parse Json
  factory Orders.fromJson(Map<String, dynamic> object) {
    return Orders(
        id: object['id'],
        idUser: object['id_user'],
        idBisnisKuliner: object['id_bisnis_kuliner'],
        idMenu: object['id_menu'],
        idDetailBundle: object['id_detail_bundle'],
        idNota: object['id_nota'],
        jumlahMakanan: object['jumlah_makanan'],
        catatanMakanan: object['catatan_makanan'],
        tanggalPemesanan: object['tanggal_pemesanan'],
        statusOrder: object['status_order'],
        keteranganOrder: object['keterangan_order']);
  }
}
