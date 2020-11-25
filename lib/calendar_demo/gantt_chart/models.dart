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
