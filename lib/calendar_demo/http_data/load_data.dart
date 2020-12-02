import 'dart:convert';
import 'package:http/http.dart' as http;

class LoadPageData {
  final List<Row> rows;
  final int human;
  final int device;

  LoadPageData({this.rows, this.human, this.device});

  factory LoadPageData.fromJson(Map<String, dynamic> json_data) {
    Iterable rowList = json_data['rows'];
    List<Row> rows = rowList.map((model) => Row.fromJson(model)).toList();
    Iterable loadList = json_data['loads'];
    List<Load> loads = loadList.map((model) => Load.fromJson(model)).toList();

    loads.map((l) => rows.map((r) => r.id == l.id ? r.loads.add(l) : {}));

    return LoadPageData(
        rows: rows, human: json_data['human'], device: json_data['device']);
  }
}

class Row {
  final String id;
  final String date; //日期
  List<Load> loads = new List<Load>(); //负载信息

  Row({this.id, this.date});

  factory Row.fromJson(Map<String, dynamic> json_data) {
    return Row(id: json_data['id'], date: json_data['date']);
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

Future<LoadPageData> fetchLoadData(http.Client client, DateTime date) async {
  // String date_url = date.year.toString() +
  //     '-' +
  //     date.month.toString() +
  //     '-' +
  //     date.day.toString();
  final response = await client.get('localhost:8080/test/load');
  // print(date);
  if (response.statusCode == 200) {
    return LoadPageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load ProgressPageData');
  }
}
