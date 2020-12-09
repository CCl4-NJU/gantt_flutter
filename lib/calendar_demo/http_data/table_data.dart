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
  final String id;
  final String name;
  final int number;
  final int shift;

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
    throw Exception('Failed to load ResourceInfoPageData');
  }
}

/** ----------------------------------- */

class OrderTablePageData {
  final List<OrderScheduleTableData> order_schedule;
  final List<OrderResourceTableData> order_resource;

  OrderTablePageData({this.order_schedule, this.order_resource});

  factory OrderTablePageData.fromJson(Map<String, dynamic> json_data) {
    Iterable schedule = json_data['schedule'];
    List<OrderScheduleTableData> os = schedule
        .map((model) => OrderScheduleTableData.fromJson(model))
        .toList();
    Iterable resource = json_data['resource'];
    List<OrderResourceTableData> or = resource
        .map((model) => OrderResourceTableData.fromJson(model))
        .toList();

    return OrderTablePageData(order_schedule: os, order_resource: or);
  }
}

class OrderScheduleTableData {
  final String id;
  final String sub_id;
  final String start;
  final String end;

  OrderScheduleTableData({this.id, this.sub_id, this.start, this.end});

  factory OrderScheduleTableData.fromJson(Map<String, dynamic> json_data) {
    return OrderScheduleTableData(
        id: json_data['id'],
        sub_id: json_data['sub_id'],
        start: json_data['start'],
        end: json_data['end']);
  }
}

class OrderResourceTableData {
  final String id;
  final String sub_id;
  final int resource_count;
  final int time_count;

  OrderResourceTableData(
      {this.id, this.sub_id, this.resource_count, this.time_count});

  factory OrderResourceTableData.fromJson(Map<String, dynamic> json_data) {
    return OrderResourceTableData(
        id: json_data['id'],
        sub_id: json_data['sub_id'],
        resource_count: json_data['resource_count'],
        time_count: json_data['time_count']);
  }
}

Future<OrderTablePageData> fetchOrderTableData(http.Client client) async {
  final response = await client.get('localhost:8080/order/info');
  // print(date);
  if (response.statusCode == 200) {
    return OrderTablePageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load OrderInfoPageData');
  }
}
