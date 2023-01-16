import 'dart:convert';
import 'package:eatme_mobileapp/models/menus.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class MenusApi {
  static Future<List<Menus>> getMenusForCustomer(
      int idBisnisKulinerCatch) async {
    String urlMenus = AppGlobalConfig.getUrlApi() + 'menus';
    final response = await http.get(Uri.parse(urlMenus));

    if (response.statusCode == 200) {
      final Map menusResponse = json.decode(response.body);
      final List menus = menusResponse['data'];

      return menus.map((json) => Menus.fromJson(json)).where((menu) {
        return menu.idBisnisKuliner == idBisnisKulinerCatch &&
            menu.makananTersedia == 1;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Menus>> getMenusForBusiness(
      int idBisnisKulinerCatch) async {
    String urlMenus = AppGlobalConfig.getUrlApi() + 'menus';
    final response = await http.get(Uri.parse(urlMenus));

    if (response.statusCode == 200) {
      final Map menusResponse = json.decode(response.body);
      final List menus = menusResponse['data'];

      return menus.map((json) => Menus.fromJson(json)).where((menu) {
        return menu.idBisnisKuliner == idBisnisKulinerCatch;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Menus>> getMenusByIdMenu(int idMenu) async {
    String urlMenus = AppGlobalConfig.getUrlApi() + 'menus';
    final response = await http.get(Uri.parse(urlMenus));

    if (response.statusCode == 200) {
      final Map menusResponse = json.decode(response.body);
      final List menus = menusResponse['data'];

      return menus.map((json) => Menus.fromJson(json)).where((menu) {
        return menu.id == idMenu;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Menus>> getAllMenus() async {
    String urlMenus = AppGlobalConfig.getUrlApi() + 'menus';
    final response = await http.get(Uri.parse(urlMenus));

    if (response.statusCode == 200) {
      final Map menusResponse = json.decode(response.body);
      final List menus = menusResponse['data'];

      return menus.map((json) => Menus.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<bool> addMenu(Map<String, String> body, String filepath) async {
    String addMenuUrl = AppGlobalConfig.getUrlApi() + 'menus';
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Connection': 'Keep-Alive'
    };

    var request = http.MultipartRequest('POST', Uri.parse(addMenuUrl))
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', filepath));

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception();
      // return false;
    }
  }

  static Future<bool> editMenu(
      int idMenu, Map<String, String> body, String filepath) async {
    String addMenuUrl =
        AppGlobalConfig.getUrlApi() + 'menus/' + idMenu.toString();
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
