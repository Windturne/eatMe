import 'dart:convert';
import 'package:eatme_mobileapp/models/order.dart';
import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class OrderApi {
  static Future<List<Orders>> getOrders(int idUser, int status) async {
    String urlOrders = AppGlobalConfig.getUrlApi() + 'order';
    final response = await http.get(Uri.parse(urlOrders));

    if (response.statusCode == 200) {
      final Map ordersResponse = json.decode(response.body);
      final List orders = ordersResponse['data'];

      return orders.map((json) => Orders.fromJson(json)).where((order) {
        return order.idUser == idUser && order.statusOrder == status;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Orders>> getOrdersByIdNota(int idNota) async {
    String urlOrders = AppGlobalConfig.getUrlApi() + 'order';
    final response = await http.get(Uri.parse(urlOrders));

    if (response.statusCode == 200) {
      final Map ordersResponse = json.decode(response.body);
      final List orders = ordersResponse['data'];

      return orders.map((json) => Orders.fromJson(json)).where((order) {
        return order.idNota == idNota;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Orders>> getOrdersByIdNotaAndUser(
      int idNota, int idUser) async {
    String urlOrders = AppGlobalConfig.getUrlApi() + 'order';
    final response = await http.get(Uri.parse(urlOrders));

    if (response.statusCode == 200) {
      final Map ordersResponse = json.decode(response.body);
      final List orders = ordersResponse['data'];

      return orders.map((json) => Orders.fromJson(json)).where((order) {
        return order.idNota == idNota && order.idUser == idUser;
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Orders>> deleteOrders(int idOrder) async {
    String urlOrders =
        AppGlobalConfig.getUrlApi() + 'order/' + idOrder.toString();
    final response = await http.delete(Uri.parse(urlOrders));

    if (response.statusCode == 200) {
      final Map ordersResponse = json.decode(response.body);
      final List orders = ordersResponse['data'];

      return orders;
    } else {
      print('Order Exception:' +
          response.body +
          ';' +
          response.statusCode.toString());
      throw Exception();
    }
  }
}
