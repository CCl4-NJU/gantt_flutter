// class User {
//   int id;
//   String name;

//   User({this.id, this.name});
// }

// class Project {
//   int id;
//   String name;
//   DateTime startTime;
//   DateTime endTime;
//   List<int> participants;

//   Project(
//       {this.id, this.name, this.startTime, this.endTime, this.participants});
// }

/** 甘特图数据模型 */
class Product {
  String id;
  String name;

  Product({this.id, this.name});
}

class Resource {
  String id;
  String name;
  DateTime startTime;
  DateTime endTime;
  List<String> productions;

  Resource(
      {this.id, this.name, this.startTime, this.endTime, this.productions});
}

/** 订单进度图数据模型 */
class OrderData {
  String id; //订单号
  List<ProgressData> crafts; //工艺信息
  bool delay; //是否延期
  OrderData(this.id, this.crafts, this.delay);
}

class ProgressData {
  String name; //工艺
  double percent;
  ProgressData(this.name, this.percent);
}

/** 负载图数据模型 */
class RowData {
  String date;
  List<BarLoad> data;
  RowData(this.date, this.data);
}

class BarLoad {
  String resource;
  int load_percent;
  BarLoad(this.resource, this.load_percent);
}
