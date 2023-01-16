import 'dart:convert';
import 'package:eatme_mobileapp/models/pemilikbisniskuliner.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class PemilikBisnisKulinerApi {
  static Future<List<PemilikBisnisKuliner>> getAllPemilikBisnisKuliner() async {
    String urlApiPemilikBisnisKuliner =
        AppGlobalConfig.getUrlApi() + 'pemilikbisniskuliner';
    final response = await http.get(Uri.parse(urlApiPemilikBisnisKuliner));

    if (response.statusCode == 200) {
      final Map pemilikBisnisKulinerResponse = json.decode(response.body);
      final List listPemilikBisnisKuliner =
          pemilikBisnisKulinerResponse['data'];

      return listPemilikBisnisKuliner
          .map((json) => PemilikBisnisKuliner.fromJson(json))
          .toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<PemilikBisnisKuliner>> getPemilikBisnisKulinerById(
      int id) async {
    String urlApiPemilikBisnisKuliner =
        AppGlobalConfig.getUrlApi() + 'pemilikbisniskuliner';
    final response = await http.get(Uri.parse(urlApiPemilikBisnisKuliner));

    if (response.statusCode == 200) {
      final Map pemilikBisnisKulinerResponse = json.decode(response.body);
      final List listPemilikBisnisKuliner =
          pemilikBisnisKulinerResponse['data'];

      return listPemilikBisnisKuliner
          .map((json) => PemilikBisnisKuliner.fromJson(json))
          .where((pemilikbisniskuliner) {
        return pemilikbisniskuliner.id == id;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<PemilikBisnisKuliner>> getPemilikBisnisKulinerByIdUser(
      int idUser) async {
    String urlApiPemilikBisnisKuliner =
        AppGlobalConfig.getUrlApi() + 'pemilikbisniskuliner';
    final response = await http.get(Uri.parse(urlApiPemilikBisnisKuliner));

    if (response.statusCode == 200) {
      final Map pemilikBisnisKulinerResponse = json.decode(response.body);
      final List listPemilikBisnisKuliner =
          pemilikBisnisKulinerResponse['data'];

      return listPemilikBisnisKuliner
          .map((json) => PemilikBisnisKuliner.fromJson(json))
          .where((pemilikbisniskuliner) {
        return pemilikbisniskuliner.idUser == idUser;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
