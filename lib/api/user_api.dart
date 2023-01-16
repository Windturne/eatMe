import 'dart:convert';
import 'package:eatme_mobileapp/models/user.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class UserApi {
  static Future<List<User>> getUserById(int idUser) async {
    String urlUser = AppGlobalConfig.getUrlApi() + 'user';
    final response = await http.get(Uri.parse(urlUser));

    if (response.statusCode == 200) {
      final Map userResponse = json.decode(response.body);
      final List users = userResponse['data'];

      return users.map((json) => User.fromJson(json)).where((user) {
        return user.id == idUser;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
