import 'dart:convert';

import 'package:eatme_mobileapp/models/formvalidasi.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class FormValidasiApi {
  static Future<bool> addFormValidasi(Map<String, String> body,
      String filepathFotoKTP, String filepathFotoSelfieKTP) async {
    String addFormUrl = AppGlobalConfig.getUrlApi() + 'formvalidasi';
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Connection': 'Keep-Alive'
    };

    var request = http.MultipartRequest('POST', Uri.parse(addFormUrl))
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('fotoKTP', filepathFotoKTP))
      ..files.add(await http.MultipartFile.fromPath(
          'fotoSelfieKTP', filepathFotoSelfieKTP));

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception();
      // return false;
    }
  }

  static Future<List<FormValidasi>> getFormByUserId(int idUser) async {
    String urlFormValidasi = AppGlobalConfig.getUrlApi() + 'formvalidasi';
    final response = await http.get(Uri.parse(urlFormValidasi));

    if (response.statusCode == 200) {
      final Map formResponse = json.decode(response.body);
      final List forms = formResponse['data'];

      return forms.map((json) => FormValidasi.fromJson(json)).where((form) {
        return form.idUser == idUser;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
