class BisnisKuliner {
  int id;
  int idPemilikBisnis;
  String namaBisnis;
  String alamatBisnis;
  String noTelp;
  String kategoriMakanan;
  String jamAmbilAwal;
  String jamAmbilAkhir;
  String fotoProfil;
  int statusValidasi;
  int statusBisnis;
  num ratingBisnis;

  //Constructor
  BisnisKuliner(
      {this.id,
      this.idPemilikBisnis,
      this.namaBisnis,
      this.alamatBisnis,
      this.noTelp,
      this.kategoriMakanan,
      this.jamAmbilAwal,
      this.jamAmbilAkhir,
      this.fotoProfil,
      this.statusValidasi,
      this.statusBisnis,
      this.ratingBisnis});

  //Parse Json
  factory BisnisKuliner.fromJson(Map<String, dynamic> object) {
    return BisnisKuliner(
        id: object['id'],
        idPemilikBisnis: object['id_pemilik_bisnis_kuliner'],
        namaBisnis: object['nama_bisnis'],
        alamatBisnis: object['alamat_bisnis'],
        noTelp: object['no_telp'],
        kategoriMakanan: object['kategori_makanan'],
        jamAmbilAwal: object['jam_ambil_awal'],
        jamAmbilAkhir: object['jam_ambil_akhir'],
        fotoProfil: object['foto_profil'],
        statusValidasi: object['status_validasi'],
        statusBisnis: object['status_bisnis'],
        ratingBisnis: object['rating_bisnis']);
  }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   ''
  // };
}
