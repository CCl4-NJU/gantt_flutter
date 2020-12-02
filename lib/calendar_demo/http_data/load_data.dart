import 'dart:convert';
import 'package:http/http.dart' as http;

class LoadPageData {
  final List<Rowd> rows;
  final int human;
  final int device;

  LoadPageData({this.rows, this.human, this.device});

  factory LoadPageData.fromJson(Map<String, dynamic> json_data) {
    Iterable rowList = json_data['rows'];
    List<Rowd> rows = rowList.map((model) => Rowd.fromJson(model)).toList();
    Iterable loadList = json_data['loads'];
    List<Load> loads = loadList.map((model) => Load.fromJson(model)).toList();

    for (Load l in loads) {
      String id = l.id;
      for (Rowd r in rows) {
        if (r.id == id) {
          r.loads.add(l);
          break;
        }
      }
    }

    return LoadPageData(
        rows: rows, human: json_data['human'], device: json_data['device']);
  }
}

class Rowd {
  final String id;
  final String date; //日期
  List<Load> loads = new List<Load>(); //负载信息

  Rowd({this.id, this.date});

  factory Rowd.fromJson(Map<String, dynamic> json_data) {
    return Rowd(id: json_data['id'], date: json_data['date']);
  }
}

class Load {
  final String id;
  final String resource; //资源名称
  final int percent; //资源负载百分数

  Load({this.id, this.resource, this.percent});

  factory Load.fromJson(Map<String, dynamic> json) {
    return Load(
        id: json['id'], resource: json['resource'], percent: json['percent']);
  }
}

Future<LoadPageData> fetchLoadData(
    http.Client client, DateTime from_date, DateTime to_date) async {
  String date_url = from_date.year.toString() +
      '-' +
      from_date.month.toString() +
      '-' +
      from_date.day.toString() +
      '/' +
      to_date.year.toString() +
      '-' +
      to_date.month.toString() +
      '-' +
      to_date.day.toString();
  final response = await client.get('localhost:8080/load/' + date_url);
  print(date_url);
  if (response.statusCode == 200) {
    return LoadPageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load ProgressPageData');
  }
}
