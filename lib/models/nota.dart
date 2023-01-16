class Nota {
  int id;
  int idUser;
  int idBisnis;
  int totalItem;
  int totalHarga;
  int statusNota;
  String tanggalPengambilan;
  int pinPengambilan;
  num ratingBisnis;
  num ratingUser;
  int statusKomplain;

  //Constructor
  Nota(
      {this.id,
      this.idUser,
      this.idBisnis,
      this.totalItem,
      this.totalHarga,
      this.statusNota,
      this.tanggalPengambilan,
      this.pinPengambilan,
      this.ratingBisnis,
      this.ratingUser,
      this.statusKomplain});

  //Parse Json
  factory Nota.fromJson(Map<String, dynamic> object) {
    return Nota(
        id: object['id'],
        idUser: object['id_user'],
        idBisnis: object['id_bisnis_kuliner'],
        totalItem: object['total_item'],
        totalHarga: object['total_harga'],
        statusNota: object['status_nota'],
        tanggalPengambilan: object['tanggal_pengambilan'],
        pinPengambilan: object['pin_pengambilan'],
        ratingBisnis: object['rating_bisnis'],
        ratingUser: object['rating_user'],
        statusKomplain: object['status_komplain']);
  }
}
