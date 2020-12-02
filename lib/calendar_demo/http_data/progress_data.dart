import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressPageData {
  // dynamic data;
  // ProgressData.fromJson(this.data);
  final List<Order> orders;
  final int rate;

  ProgressPageData({this.orders, this.rate});

  factory ProgressPageData.fromJson(Map<String, dynamic> json_data) {
    Iterable orderList = json_data['orders'];
    List<Order> orders =
        orderList.map((model) => Order.fromJson(model)).toList();
    Iterable craftList = json_data['crafts'];
    List<Progress> crafts =
        craftList.map((model) => Progress.fromJson(model)).toList();

    for (Progress craft in crafts) {
      String orderId = craft.id;
      for (Order order in orders) {
        if (order.id == orderId) {
          order.crafts.add(craft);
          break;
        }
      }
    }

    return ProgressPageData(orders: orders, rate: json_data['rate']);
  }
}

class Order {
  final String id; //订单号
  List<Progress> crafts = new List<Progress>(); //工艺信息
  final bool delay; //是否延期

  Order({this.id, this.delay});

  factory Order.fromJson(Map<String, dynamic> json_data) {
    return Order(id: json_data['id'], delay: json_data['delay']);
  }
}

class Progress {
  final String id;
  final String name; //工艺
  final double percent;

  Progress({this.id, this.name, this.percent});

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
        id: json['id'], name: json['name'], percent: json['percent']);
  }
}

Future<ProgressPageData> fetchProgressData(
    http.Client client, DateTime date) async {
  String date_url = date.year.toString() +
      '-' +
      date.month.toString() +
      '-' +
      date.day.toString();
  final response = await client.get('localhost:8080/progress/' + date_url);
  // print(date);
  if (response.statusCode == 200) {
    return ProgressPageData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load ProgressPageData');
  }
}
