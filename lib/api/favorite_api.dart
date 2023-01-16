import 'dart:convert';
import 'package:eatme_mobileapp/models/favorite.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class FavoriteApi {
  static Future<List<Favorite>> getFavorite() async {
    String urlFavorite = AppGlobalConfig.getUrlApi() + 'favorite';
    final response = await http.get(Uri.parse(urlFavorite));

    if (response.statusCode == 200) {
      final Map favoriteResponse = json.decode(response.body);
      final List favorites = favoriteResponse['data'];

      return favorites.map((json) => Favorite.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Favorite>> getFavoriteByIdBisnis(int idBisnis) async {
    String urlFavorite = AppGlobalConfig.getUrlApi() + 'favorite';
    final response = await http.get(Uri.parse(urlFavorite));

    if (response.statusCode == 200) {
      final Map favoriteResponse = json.decode(response.body);
      final List favorites = favoriteResponse['data'];

      return favorites.map((json) => Favorite.fromJson(json)).where((favorite) {
        return favorite.idBisnisKuliner == idBisnis;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Favorite>> getFavoriteByIdBisnisAndUser(
      int idBisnis, int idUser) async {
    String urlFavorite = AppGlobalConfig.getUrlApi() + 'favorite';
    final response = await http.get(Uri.parse(urlFavorite));

    if (response.statusCode == 200) {
      final Map favoriteResponse = json.decode(response.body);
      final List favorites = favoriteResponse['data'];

      return favorites.map((json) => Favorite.fromJson(json)).where((favorite) {
        return favorite.idBisnisKuliner == idBisnis &&
            favorite.idUser == idUser;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
