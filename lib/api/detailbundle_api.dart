import 'dart:convert';
import 'package:eatme_mobileapp/models/detailbundle.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class DetailBundleApi {
  static Future<List<DetailBundle>> getAllBundle() async {
    String urlBundle = AppGlobalConfig.getUrlApi() + 'bundle';
    final response = await http.get(Uri.parse(urlBundle));

    if (response.statusCode == 200) {
      final Map bundleResponse = json.decode(response.body);
      print('bundleResponse: ${bundleResponse}');
      final List bundles = bundleResponse['data'];

      return bundles.map((json) => DetailBundle.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<DetailBundle>> getBundleByIdMenu(int idMenuCatch) async {
    String urlBundle = AppGlobalConfig.getUrlApi() + 'bundle';
    final response = await http.get(Uri.parse(urlBundle));

    if (response.statusCode == 200) {
      final Map bundleResponse = json.decode(response.body);
      print('bundleResponse: ${bundleResponse}');
      final List bundles = bundleResponse['data'];

      return bundles.map((json) => DetailBundle.fromJson(json)).where((bundle) {
        return bundle.idMenu == idMenuCatch;
      }).toList();
    } else {
      throw Exception();
    }
  }
}
