import 'dart:convert';
import 'package:eatme_mobileapp/models/transaksi.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../appGlobalConfig.dart';

class TransaksiEwalletApi {
  static Future<List<Transaksi>> getTransaksiByTanggal(
      String date, int idUser) async {
    String urlTransaksiEwallet = AppGlobalConfig.getUrlApi() + 'transaksi';
    final response = await http.get(Uri.parse(urlTransaksiEwallet));

    if (response.statusCode == 200) {
      final Map transaksiEwalletResponse = json.decode(response.body);
      final List transactions = transaksiEwalletResponse['data'];

      return transactions
          .map((json) => Transaksi.fromJson(json))
          .where((transaction) {
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        String tanggalTransaksi =
            formatter.format(DateTime.parse(transaction.tanggalTransaksi));
        return transaction.idUser == idUser && tanggalTransaksi == date;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<bool> addTransaksi(
      Map<String, String> body, String filepath) async {
    String addTransaksiUrl = AppGlobalConfig.getUrlApi() + 'transaksi';
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Connection': 'Keep-Alive'
    };

    var request = http.MultipartRequest('POST', Uri.parse(addTransaksiUrl))
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', filepath));

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      // throw Exception();
      return false;
    }
  }
}
