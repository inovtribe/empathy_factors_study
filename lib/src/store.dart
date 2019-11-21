import 'dart:io';

import 'package:grizzly_io/grizzly_io.dart';

class Store {
  Store._(this.file, this.data);
  factory Store() => _instance;
  factory Store.init(File file, Map<DateTime, List<dynamic>> data) => _instance = Store._(file, data);

  static Store _instance;

  final Map<DateTime, List<dynamic>> data;
  final File file;

  DateTime current;

  Future<void> save() {
    final encoded = encodeCsv(data.entries.map<List<dynamic>>((e) => [e.key.toIso8601String(), ...e.value.map<String>(encode)]).toList());
    return file.writeAsString(encoded);
  }

  static Future<void> load(File file) async {
    if (!file.existsSync()) {
      _instance = Store._(file, {});
      return;
    }
    _instance = Store._(file, parseCsv(await file.readAsString()).asMap().map<DateTime, List<dynamic>>((_, e) => MapEntry(DateTime.parse(e[0]), e.skip(1).toList())));
  }

  void start(DateTime dateTime, {int len = LEN}) {
    current = dateTime;
    data[current] = List(len);
    data[current][EQ] = 0;
  }

  void add(int toAdd) => data[current][EQ] += toAdd;

  dynamic operator [](int key) => data[current][key];
  operator []=(int key, dynamic newValue) => data[current][key] = newValue;

  static const EQ = 0, HOURS_VG = 1, HOURS_VG_V = 2, LEN = 32;

  static String encode(dynamic v) {
    if (v is Duration) {
      return (v.inMinutes / 60).toString();
    } else if (v is DateTime) {
      return v.toIso8601String();
    } else {
      return v.toString();
    }
  }
}
