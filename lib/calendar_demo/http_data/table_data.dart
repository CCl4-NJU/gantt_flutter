import 'dart:convert';
import 'package:http/http.dart' as http;

class ResourceTablePageData {
  // dynamic data;
  // ProgressData.fromJson(this.data);
  final List<ResourceTableData> human;
  final List<ResourceTableData> device;

  ResourceTablePageData({this.human, this.device});

  factory ResourceTablePageData.fromJson(Map<String, dynamic> json_data) {
    Iterable humans = json_data['human'];
    List<ResourceTableData> human_list =
        humans.map((model) => ResourceTableData.fromJson(model)).toList();
    Iterable devices = json_data['device'];
    List<ResourceTableData> device_list =
        devices.map((model) => ResourceTableData.fromJson(model)).toList();

    return ResourceTablePageData(human: human_list, device: device_list);
  }
}

class ResourceTableData {
  final String id; //订单号
  final String name; //工艺信息
  final int number;
  final int shift; //是否延期

  ResourceTableData({this.id, this.name, this.number, this.shift});

  factory ResourceTableData.fromJson(Map<String, dynamic> json_data) {
    return ResourceTableData(
        id: json_data['id'],
        name: json_data['name'],
        number: json_data['number'],
        shift: json_data['shift']);
  }
}

Future<ResourceTablePageData> fetchResourceTableData(http.Client client) async {
  final response = await client.get('localhost:8080/resource/info');
  // print(date);
  if (response.statusCode == 200) {
    return ResourceTablePageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load ProgressPageData');
  }
}
