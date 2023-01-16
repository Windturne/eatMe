class Favorite {
  int id;
  int idUser;
  int idBisnisKuliner;

  //Constructor
  Favorite({this.id, this.idUser, this.idBisnisKuliner});

  //Parse Json
  factory Favorite.fromJson(Map<String, dynamic> object) {
    return Favorite(
        id: object['id'],
        idUser: object['id_user'],
        idBisnisKuliner: object['id_bisnis_kuliner']);
  }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   ''
  // };
}
