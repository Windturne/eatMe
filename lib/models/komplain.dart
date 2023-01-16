class Komplain {
  int id;
  int idNota;
  String deskripsiKomplain;
  String gambarKomplain;
  String sender;

  //Constructor
  Komplain(
      {this.id,
      this.idNota,
      this.deskripsiKomplain,
      this.gambarKomplain,
      this.sender});

  //Parse Json
  factory Komplain.fromJson(Map<String, dynamic> object) {
    return Komplain(
        id: object['id'],
        idNota: object['id_nota'],
        deskripsiKomplain: object['deskripsi_komplain'],
        gambarKomplain: object['gambar_komplain'],
        sender: object['sender']);
  }
}
