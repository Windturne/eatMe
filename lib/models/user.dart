class User {
  int id;
  String name;
  String email;
  int saldoEwallet;
  int makananDiselamatkan;
  num ratingUser;
  String tokenNotifikasi;

  //Constructor
  User(
      {this.id,
      this.name,
      this.email,
      this.saldoEwallet,
      this.makananDiselamatkan,
      this.ratingUser,
      this.tokenNotifikasi});

  //Parse Json
  factory User.fromJson(Map<String, dynamic> object) {
    return User(
        id: object['id'],
        name: object['name'],
        email: object['email'],
        saldoEwallet: object['saldo_ewallet'],
        makananDiselamatkan: object['makanan_diselamatkan'],
        ratingUser: object['rating_user'],
        tokenNotifikasi: object['token_notifikasi']);
  }
}
