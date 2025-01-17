import 'database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DataInitializer {

  static Future<void> initializeData() async {
    if (kIsWeb) {
      // 웹 환경에서는 sqflite_common_ffi_web 초기화
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // 데스크톱 환경 초기화
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    print('데이터 초기화 이전!');
    final Map<String, double> congestionData = {
      '5시30분': 8.6,
      '6시00분': 20.9,
      '6시30분': 20.3,
      '7시00분': 33.1,
      '7시30분': 61.3,
      '8시00분': 66.0,
      '8시30분': 86.6,
      '9시00분': 63.6,
      '9시30분': 62.9,
      '10시00분': 38.5,
      '10시30분': 44.2,
      // 나머지 데이터 추가
    };

    final String stationName = '서울역';
    final String direction = '상선';

    await DatabaseHelper.instance.insertData(stationName, direction, congestionData);
    print('데이터 초기화 완료!');
  }
}
