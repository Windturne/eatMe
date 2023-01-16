class Menus {
  int id;
  int idBisnisKuliner;
  int isBundle;
  String namaMakanan;
  int hargaMakanan;
  int hargaSebelumDiskon;
  String deskripsiMakanan;
  int makananTersedia;
  String fotoMenu;

  //Constructor
  Menus(
      {this.id,
      this.idBisnisKuliner,
      this.isBundle,
      this.namaMakanan,
      this.hargaMakanan,
      this.hargaSebelumDiskon,
      this.deskripsiMakanan,
      this.makananTersedia,
      this.fotoMenu});

  //Parse Json
  factory Menus.fromJson(Map<String, dynamic> object) {
    return Menus(
        id: object['id'],
        idBisnisKuliner: object['id_bisnis_kuliner'],
        isBundle: object['isBundle'],
        namaMakanan: object['nama_makanan'],
        hargaMakanan: object['harga_makanan'],
        hargaSebelumDiskon: object['harga_sebelum_diskon'],
        deskripsiMakanan: object['deskripsi_makanan'],
        makananTersedia: object['makanan_tersedia'],
        fotoMenu: object['foto_menu']);
  }
}
