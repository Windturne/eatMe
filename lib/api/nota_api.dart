import 'dart:convert';
import 'package:eatme_mobileapp/models/nota.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class NotaApi {
  static Future<List<Nota>> getNotaByIdBisnis(
      int idBisnis, int statusNota) async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return nota.idBisnis == idBisnis && nota.statusNota == statusNota;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Nota>> getNotaByIdUser(int idUser, int statusNota) async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return nota.idUser == idUser && nota.statusNota == statusNota;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Nota>> getNotaByIdNota(int idNota) async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return nota.id == idNota;
      }).toList();
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  static Future<List<Nota>> getAllPinCodes() async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return nota.pinPengambilan != null;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Nota>> getRataRataBisnis(int idBisnis) async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return (nota.idBisnis == idBisnis &&
                nota.statusKomplain == 0 &&
                nota.statusNota == 2) ||
            (nota.idBisnis == idBisnis &&
                nota.statusKomplain == 2 &&
                nota.statusNota == 2);
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Nota>> getRataRataUser(int idUser) async {
    String urlNota = AppGlobalConfig.getUrlApi() + 'nota';
    final response = await http.get(Uri.parse(urlNota));

    if (response.statusCode == 200) {
      final Map notaResponse = json.decode(response.body);
      final List notas = notaResponse['data'];

      return notas.map((json) => Nota.fromJson(json)).where((nota) {
        return (nota.idUser == idUser &&
                nota.statusKomplain == 0 &&
                nota.statusNota == 2) ||
            (nota.idUser == idUser &&
                nota.statusKomplain == 2 &&
                nota.statusNota == 2);
      }).toList();
    } else {
      throw Exception();
    }
  }
}
