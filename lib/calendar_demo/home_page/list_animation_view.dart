import 'package:gantt_flutter/calendar_demo/home_page/PageItem.dart';
import 'package:gantt_flutter/calendar_demo/home_page/list_animation_item.dart';
import 'package:flutter/material.dart';

class ListAnimationView extends StatefulWidget {
  List<Item> pages;

  ListAnimationView({Key key, @required this.pages}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListAnimationViewState();
  }
}

class _ListAnimationViewState extends State<ListAnimationView> {
  List<Item> _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pages = widget.pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              child: ListAnimationItem(
            page: _pages[index],
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => _pages[index].page));
            },
          ));
        },
      ),
    );
  }
}
