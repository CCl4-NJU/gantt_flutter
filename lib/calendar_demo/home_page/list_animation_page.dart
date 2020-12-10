import 'package:gantt_flutter/calendar_demo/home_page/list_animation_view.dart';
import 'PageItem.dart';
import 'package:flutter/material.dart';

class ListAnimationPage extends StatefulWidget {
  final List<Item> pages;

  ListAnimationPage({Key key, @required this.pages}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListAnimationPageState();
  }
}

class _ListAnimationPageState extends State<ListAnimationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListAnimationView(pages: widget.pages),
    );
  }
}
