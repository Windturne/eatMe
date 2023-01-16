class DetailBundle {
  int id;
  int idMenu;
  String isiMenu;
  String deskripsi;

  //Constructor
  DetailBundle({this.id, this.idMenu, this.isiMenu, this.deskripsi});

  //Parse Json
  factory DetailBundle.fromJson(Map<String, dynamic> object) {
    return DetailBundle(
        id: object['id'],
        idMenu: object['id_menu'],
        isiMenu: object['isi_bundle'],
        deskripsi: object['deskripsi']);
  }
}
