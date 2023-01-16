import 'package:http/http.dart' as http;

import '../appGlobalConfig.dart';

class KomplainApi {
  static Future<bool> addKomplain(
      Map<String, String> body, String filepath) async {
    String addMenuUrl = AppGlobalConfig.getUrlApi() + 'komplain';
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
