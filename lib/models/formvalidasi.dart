class FormValidasi {
  int id;
  int idUser;
  String namaBisnis;
  String alamatBisnis;
  String namaPemilik;
  String noKTP;
  String alamatPemilik;
  String noTelpPemilik;
  String emailPemilik;
  String fotoKTP;
  String fotoSelfieKTP;
  String noRekening;
  String namaRekening;
  String bankRekening;
  int validasiAdmin;

  //Constructor
  FormValidasi(
      {this.id,
      this.idUser,
      this.namaBisnis,
      this.alamatBisnis,
      this.namaPemilik,
      this.noKTP,
      this.alamatPemilik,
      this.noTelpPemilik,
      this.emailPemilik,
      this.fotoKTP,
      this.fotoSelfieKTP,
      this.noRekening,
      this.namaRekening,
      this.bankRekening,
      this.validasiAdmin});

  //Parse Json
  factory FormValidasi.fromJson(Map<String, dynamic> object) {
    return FormValidasi(
      id: object['id'],
      idUser: object['id_user'],
      namaBisnis: object['nama_bisnis'],
      alamatBisnis: object['alamat_bisnis'],
      namaPemilik: object['nama_pemilik'],
      noKTP: object['no_ktp'],
      alamatPemilik: object['alamat_pemilik'],
      noTelpPemilik: object['no_telp_pemilik'],
      emailPemilik: object['email_pemilik'],
      fotoKTP: object['foto_ktp'],
      fotoSelfieKTP: object['foto_selfie_ktp'],
      noRekening: object['no_rekening'],
      namaRekening: object['nama_rekening'],
      bankRekening: object['bank_rekening'],
      validasiAdmin: object['validasi_admin'],
    );
  }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   ''
  // };
}
