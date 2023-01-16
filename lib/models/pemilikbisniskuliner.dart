class PemilikBisnisKuliner {
  int id;
  int idUser;
  String namaPemilik;
  String noKTP;
  String jenisKelamin;
  String alamatPemilik;
  String noTelp;
  String emailPemilik;
  String noRekening;
  String namaRekening;
  String bankRekening;

  //Constructor
  PemilikBisnisKuliner(
      {this.id,
      this.idUser,
      this.namaPemilik,
      this.noKTP,
      this.jenisKelamin,
      this.alamatPemilik,
      this.noTelp,
      this.emailPemilik,
      this.noRekening,
      this.namaRekening,
      this.bankRekening});

  //Parse Json
  factory PemilikBisnisKuliner.fromJson(Map<String, dynamic> object) {
    return PemilikBisnisKuliner(
        id: object['id'],
        idUser: object['id_user'],
        namaPemilik: object['nama_pemilik'],
        noKTP: object['no_ktp'],
        jenisKelamin: object['jenis_kelamin'],
        alamatPemilik: object['alamat_pemilik'],
        noTelp: object['no_telp'],
        emailPemilik: object['email_pemilik'],
        noRekening: object['no_rekening'],
        namaRekening: object['nama_rekening'],
        bankRekening: object['bank_rekening']);
  }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   ''
  // };
}
