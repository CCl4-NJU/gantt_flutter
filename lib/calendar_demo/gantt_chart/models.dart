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
  int id;
  String name;

  Product({this.id, this.name});
}

class Resource {
  int id;
  String name;
  DateTime startTime;
  DateTime endTime;
  List<int> productions;

  Resource(
      {this.id, this.name, this.startTime, this.endTime, this.productions});
}

/** 订单进度图数据模型 */
class OrderData {
  String id; //订单号
  List<ProgressData> crafts; //工艺信息
  bool delay; //是否延期
  String deal; //约定交期
  String expc; //预计交期
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
