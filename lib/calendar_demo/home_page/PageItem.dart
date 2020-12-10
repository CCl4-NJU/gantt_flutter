import 'package:flutter/material.dart';

class Item {
  final String name;
  final String image;
  final String description;
  StatefulWidget page;
  bool isCheck = false;

  Item({this.name, this.image, this.description, this.page});
}
