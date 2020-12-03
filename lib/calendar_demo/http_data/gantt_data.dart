import 'dart:convert';
import 'package:http/http.dart' as http;

class GanttPageData {
  final List<ResourceData> resources;
  final List<ProductData> products;

  GanttPageData({this.resources, this.products});

  factory GanttPageData.fromJson(Map<String, dynamic> json_data) {
    Iterable resourceList = json_data['resources'];
    List<ResourceData> resources =
        resourceList.map((model) => ResourceData.fromJson(model)).toList();
    Iterable productList = json_data['products'];
    List<ProductData> products =
        productList.map((model) => ProductData.fromJson(model)).toList();

    return GanttPageData(resources: resources, products: products);
  }
}

class ResourceData {
  final String id;
  final String name; //资源名称
  final DateTime startTime;
  final DateTime endTime;
  List<String> productions = new List<String>(); //负责产品id

  ResourceData(
      {this.id, this.name, this.startTime, this.endTime, this.productions});

  factory ResourceData.fromJson(Map<String, dynamic> json_data) {
    String start_str = json_data['startTime'];
    String end_str = json_data['endTime'];

    List<String> sp = start_str.split("-"); //start_params
    List<String> ep = end_str.split("-"); //end_params

    DateTime start_time = DateTime(int.parse(sp[0]), int.parse(sp[1]),
        int.parse(sp[2]), int.parse(sp[3]), int.parse(sp[4]));
    DateTime end_time = DateTime(int.parse(ep[0]), int.parse(ep[1]),
        int.parse(ep[2]), int.parse(ep[3]), int.parse(ep[4]));

    List<String> prod = new List<String>();
    prod.add(json_data['productId']);

    return ResourceData(
        id: json_data['id'],
        name: json_data['name'],
        startTime: start_time,
        endTime: end_time,
        productions: prod);
  }
}

class ProductData {
  final String id;
  final String name; //产品名

  ProductData({this.id, this.name});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(id: json['id'], name: json['name']);
  }
}

Future<GanttPageData> fetchResourceData(
    http.Client client, DateTime date) async {
  String date_url = date.year.toString() +
      '-' +
      date.month.toString() +
      '-' +
      date.day.toString();
  final response = await client.get('localhost:8080/test/resource');
  // print(date);
  if (response.statusCode == 200) {
    return GanttPageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load ProgressPageData');
  }
}
