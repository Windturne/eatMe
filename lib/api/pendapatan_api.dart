import 'dart:convert';
import 'package:eatme_mobileapp/models/pendapatan.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../appGlobalConfig.dart';

class PendapatanApi {
  static Future<List<Pendapatan>> getPendapatanByTanggal(
      String date, int idBisnis) async {
    String urlPendapatan = AppGlobalConfig.getUrlApi() + 'pendapatan';
    final response = await http.get(Uri.parse(urlPendapatan));

    if (response.statusCode == 200) {
      final Map pendapatanResponse = json.decode(response.body);
      final List pendapatans = pendapatanResponse['data'];

      return pendapatans
          .map((json) => Pendapatan.fromJson(json))
          .where((pendapatan) {
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        String tanggalPendapatan =
            formatter.format(DateTime.parse(pendapatan.tanggalPendapatan));
        return pendapatan.idBisnisKuliner == idBisnis &&
            tanggalPendapatan == date;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
