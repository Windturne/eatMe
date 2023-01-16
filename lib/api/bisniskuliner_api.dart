import 'dart:convert';
import 'package:eatme_mobileapp/models/bisniskuliner.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class BisnisKulinerApi {
  static Future<List<BisnisKuliner>> getBisnisKuliner(String query) async {
    String urlApiBisnisKuliner = AppGlobalConfig.getUrlApi() + 'bisniskuliner';
    final response = await http.get(Uri.parse(urlApiBisnisKuliner));

    if (response.statusCode == 200) {
      final Map bisnisKulinerResponse = json.decode(response.body);
      final List listBisnisKuliner = bisnisKulinerResponse['data'];

      return listBisnisKuliner
          .map((json) => BisnisKuliner.fromJson(json))
          .where((bisniskuliner) {
        final namaBisnisLower = bisniskuliner.namaBisnis.toLowerCase();
        final searchLower = query.toLowerCase();
        // print('namaLower:' + namaBisnisLower + ' | searchLower:' + searchLower);

        return namaBisnisLower.contains(searchLower) &&
            bisniskuliner.statusValidasi == 1 &&
            bisniskuliner.statusBisnis == 1;
      }).toList();
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  static Future<List<BisnisKuliner>> getAllBisnisKuliner() async {
    String urlApiBisnisKuliner = AppGlobalConfig.getUrlApi() + 'bisniskuliner';
    final response = await http.get(Uri.parse(urlApiBisnisKuliner));

    if (response.statusCode == 200) {
      final Map bisnisKulinerResponse = json.decode(response.body);
      final List listBisnisKuliner = bisnisKulinerResponse['data'];

      return listBisnisKuliner
          .map((json) => BisnisKuliner.fromJson(json))
          .toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<BisnisKuliner>> getBisnisKulinerById(int id) async {
    String urlApiBisnisKuliner = AppGlobalConfig.getUrlApi() + 'bisniskuliner';
    final response = await http.get(Uri.parse(urlApiBisnisKuliner));

    if (response.statusCode == 200) {
      final Map bisnisKulinerResponse = json.decode(response.body);
      final List listBisnisKuliner = bisnisKulinerResponse['data'];

      return listBisnisKuliner
          .map((json) => BisnisKuliner.fromJson(json))
          .where((bisniskuliner) {
        return bisniskuliner.id == id;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<BisnisKuliner>> getBisnisKulinerByIdPemilik(int id) async {
    String urlApiBisnisKuliner = AppGlobalConfig.getUrlApi() + 'bisniskuliner';
    final response = await http.get(Uri.parse(urlApiBisnisKuliner));

    if (response.statusCode == 200) {
      final Map bisnisKulinerResponse = json.decode(response.body);
      final List listBisnisKuliner = bisnisKulinerResponse['data'];

      return listBisnisKuliner
          .map((json) => BisnisKuliner.fromJson(json))
          .where((bisniskuliner) {
        return bisniskuliner.idPemilikBisnis == id;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<bool> editBisnisKuliner(
      int idBisnisKuliner, Map<String, String> body, String filepath) async {
    String addMenuUrl = AppGlobalConfig.getUrlApi() +
        'bisniskuliner/' +
        idBisnisKuliner.toString();
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Connection': 'Keep-Alive'
    };

    var request = http.MultipartRequest('POST', Uri.parse(addMenuUrl))
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', filepath));

    print('Filepath API: ' + filepath);

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception();
      // return false;
    }
  }
}
