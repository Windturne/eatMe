import 'dart:async';
import 'dart:convert';

import 'package:eatme_mobileapp/api/nota_api.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/bisniskuliner_api.dart';
import 'api/user_api.dart';
import 'models/nota.dart';
import 'package:http/http.dart' as http;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class AppGlobalConfig {
  static String getUrlApi() {
    return 'https://eatme.asia/api/';
    // return 'http://192.168.0.127/api/';
  }

  static String getUrlStorage() {
    return 'https://eatme.asia/storage/';
    // return 'http://192.168.0.127/api/';
  }

  static titleCase(text) {
    if (text == null) {
      return null;
    }

    if (text.length <= 1) {
      return text.toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = text.split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }

  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }

  static Future sendPushNotification(
      List<String> tokenIdList, String contents, String heading) async {
    final response = await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": "46dd1a17-7a49-44e2-bbd8-04b1c052b8dc",
        "android_sound": "eatme_notification.wav",
        "android_channel_id": "0a6e0a43-bae8-4738-bcdf-98f420f2003c",
        "include_player_ids": tokenIdList,
        // "include_external_user_ids": externalIds,
        // "channel_for_external_user_ids": "push",
        "headings": {"en": heading},
        "contents": {"en": contents},
      }),
    );

    if (response.statusCode == 200) {
      print('NOTIF BERHASIL');
    } else {
      print('NOTIF GAGAL: ' + response.statusCode.toString());
    }

    return response;
  }

  static Future cekRating() async {
    print('Alarm fired at ${DateTime.now()}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var notaId = prefs.getInt('notaID');

    final newNota = await NotaApi.getNotaByIdNota(notaId);
    final nota = newNota[0];

    //Cek apakah user sudah kasih rating
    if (newNota[0].ratingBisnis == 0) {
      //ADD rating bisnis ke tabel nota
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'nota/' + notaId.toString()),
          body: {
            'rating_bisnis': '5',
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }

      //EDIT rata2 rating di id bisnis kuliner
      final bisnis = await BisnisKulinerApi.getBisnisKulinerById(nota.idBisnis);
      if (bisnis[0].ratingBisnis == 0) {
        final response = await http.put(
            Uri.parse(AppGlobalConfig.getUrlApi() +
                'bisniskuliner/' +
                bisnis[0].id.toString()),
            body: {
              'rating_bisnis': '5',
            },
            headers: {
              'Accept': 'application/json'
            });

        if (response.statusCode == 200) {
          print(response.body);
        }
      } else {
        double sumAll = 0;
        final listRating = await NotaApi.getRataRataBisnis(bisnis[0].id);
        for (int i = 0; i < listRating.length; i++) {
          sumAll += listRating[i].ratingBisnis;
        }
        final ratingMean = sumAll / listRating.length;

        final response = await http.put(
            Uri.parse(AppGlobalConfig.getUrlApi() +
                'bisniskuliner/' +
                bisnis[0].id.toString()),
            body: {
              'rating_bisnis': ratingMean.toString(),
            },
            headers: {
              'Accept': 'application/json'
            });

        if (response.statusCode == 200) {
          print(response.body);
        }
      }

      //Add pendapatan ke bisnis kuliner
      final urlApiPendapatan = AppGlobalConfig.getUrlApi() + 'pendapatan';
      final komisiPendapatan = nota.totalHarga * 0.1;
      final responsePendapatan = await http.post(Uri.parse(urlApiPendapatan),
          headers: {
            "Content-Type": "application/json; charset=utf-8",
          },
          body: json.encode({
            'id_bisnis_kuliner': nota.idBisnis.toString(),
            'id_nota': nota.id.toString(),
            'total_harga': nota.totalHarga.toString(),
            'komisi': komisiPendapatan.toString(),
            'pendapatan_bersih':
                (nota.totalHarga - komisiPendapatan).toString(),
            'tanggal_pendapatan': nota.tanggalPengambilan
          }));

      if (responsePendapatan.statusCode == 200) {
        print(responsePendapatan.body);
      }
    } //if user

    //Cek apakah bisnis sudah kasih rating
    if (newNota[0].ratingUser == 0) {
      //ADD rating user ke tabel nota
      final response = await http.put(
          Uri.parse(AppGlobalConfig.getUrlApi() + 'nota/' + nota.id.toString()),
          body: {
            'rating_user': '5',
          },
          headers: {
            'Accept': 'application/json'
          });

      if (response.statusCode == 200) {
        print(response.body);
      }

      //EDIT rata2 rating di id user
      final user = await UserApi.getUserById(nota.idUser);
      if (user[0].ratingUser == 0) {
        final response = await http.put(
            Uri.parse(
                AppGlobalConfig.getUrlApi() + 'user/' + user[0].id.toString()),
            body: {
              'rating_user': '5',
            },
            headers: {
              'Accept': 'application/json'
            });

        if (response.statusCode == 200) {
          print(response.body);
        }
      } else {
        double sumAll = 0;
        final listRating = await NotaApi.getRataRataUser(user[0].id);
        for (int i = 0; i < listRating.length; i++) {
          sumAll += listRating[i].ratingUser;
        }
        final ratingMean = sumAll / listRating.length;

        final response = await http.put(
            Uri.parse(
                AppGlobalConfig.getUrlApi() + 'user/' + user[0].id.toString()),
            body: {
              'rating_user': ratingMean.toString(),
            },
            headers: {
              'Accept': 'application/json'
            });

        if (response.statusCode == 200) {
          print(response.body);
        }
      }
    }

    //Remove alarm and prefs
    AndroidAlarmManager.cancel(1);
    prefs.remove('notaID');
  }

  static Future startTimer(Nota nota) async {
    print('masuk start timer');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('notaID', nota.id);

    final int alarmID = 1;

    //Cek Rating 3 jam
    AndroidAlarmManager.oneShot(Duration(minutes: 1), alarmID, cekRating);
  }

  // static void fireAlarm() {
  //   print('Alarm fires at ${DateTime.now()}');
  // }

  // static Future startTimer(Nota nota) async {
  //   Timer timer;
  //   int seconds = 10800;

  //   //Start timer untuk rating otomatis setelah 3 jam -> untuk user dan bisnis kuliner
  //   timer = Timer.periodic(Duration(seconds: 1), (_) async {
  //     print('MASUK TIMER');

  //     //Detik masih jalan
  //     if (seconds > 0) {
  //       seconds--;
  //       // if (!mounted) return;
  //       // setState(() {
  //       //   this.seconds--;
  //       // });
  //     } else {
  //       final newNota = await NotaApi.getNotaByIdNota(nota.id);

  //       //Cek apakah user sudah kasih rating
  //       if (newNota[0].ratingBisnis == 0) {
  //         //ADD rating bisnis ke tabel nota
  //         final response = await http.put(
  //             Uri.parse(
  //                 AppGlobalConfig.getUrlApi() + 'nota/' + nota.id.toString()),
  //             body: {
  //               'rating_bisnis': '5',
  //             },
  //             headers: {
  //               'Accept': 'application/json'
  //             });

  //         if (response.statusCode == 200) {
  //           print(response.body);
  //         }

  //         //EDIT rata2 rating di id bisnis kuliner
  //         final bisnis =
  //             await BisnisKulinerApi.getBisnisKulinerById(nota.idBisnis);
  //         if (bisnis[0].ratingBisnis == 0) {
  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'bisniskuliner/' +
  //                   bisnis[0].id.toString()),
  //               body: {
  //                 'rating_bisnis': '5',
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         } else {
  //           double sumAll = 0;
  //           final listRating = await NotaApi.getRataRataBisnis(bisnis[0].id);
  //           for (int i = 0; i < listRating.length; i++) {
  //             sumAll += listRating[i].ratingBisnis;
  //           }
  //           final ratingMean = sumAll / listRating.length;

  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'bisniskuliner/' +
  //                   bisnis[0].id.toString()),
  //               body: {
  //                 'rating_bisnis': ratingMean.toString(),
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         }

  //         //Add pendapatan ke bisnis kuliner
  //         final urlApiPendapatan = AppGlobalConfig.getUrlApi() + 'pendapatan';
  //         final komisiPendapatan = nota.totalHarga * 0.1;
  //         final responsePendapatan =
  //             await http.post(Uri.parse(urlApiPendapatan),
  //                 headers: {
  //                   "Content-Type": "application/json; charset=utf-8",
  //                 },
  //                 body: json.encode({
  //                   'id_bisnis_kuliner': nota.idBisnis.toString(),
  //                   'id_nota': nota.id.toString(),
  //                   'total_harga': nota.totalHarga.toString(),
  //                   'komisi': komisiPendapatan.toString(),
  //                   'pendapatan_bersih':
  //                       (nota.totalHarga - komisiPendapatan).toString(),
  //                   'tanggal_pendapatan': nota.tanggalPengambilan
  //                 }));

  //         if (responsePendapatan.statusCode == 200) {
  //           print(responsePendapatan.body);
  //         }
  //       } //if user

  //       //Cek apakah bisnis sudah kasih rating
  //       if (newNota[0].ratingUser == 0) {
  //         //ADD rating user ke tabel nota
  //         final response = await http.put(
  //             Uri.parse(
  //                 AppGlobalConfig.getUrlApi() + 'nota/' + nota.id.toString()),
  //             body: {
  //               'rating_user': '5',
  //             },
  //             headers: {
  //               'Accept': 'application/json'
  //             });

  //         if (response.statusCode == 200) {
  //           print(response.body);
  //         }

  //         //EDIT rata2 rating di id user
  //         final user = await UserApi.getUserById(nota.idUser);
  //         if (user[0].ratingUser == 0) {
  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'user/' +
  //                   user[0].id.toString()),
  //               body: {
  //                 'rating_user': '5',
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         } else {
  //           double sumAll = 0;
  //           final listRating = await NotaApi.getRataRataUser(user[0].id);
  //           for (int i = 0; i < listRating.length; i++) {
  //             sumAll += listRating[i].ratingUser;
  //           }
  //           final ratingMean = sumAll / listRating.length;

  //           final response = await http.put(
  //               Uri.parse(AppGlobalConfig.getUrlApi() +
  //                   'user/' +
  //                   user[0].id.toString()),
  //               body: {
  //                 'rating_user': ratingMean.toString(),
  //               },
  //               headers: {
  //                 'Accept': 'application/json'
  //               });

  //           if (response.statusCode == 200) {
  //             print(response.body);
  //           }
  //         }
  //       }

  //       //Stop timer
  //       timer.cancel();
  //     }
  //     print('DETIK RATING: ' + seconds.toString());
  //   });
  // }
}
