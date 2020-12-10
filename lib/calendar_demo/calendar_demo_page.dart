import 'package:flutter/material.dart';
import 'package:gantt_flutter/calendar_demo/gantt_chart/gantt_chart_screen.dart';
import 'package:gantt_flutter/calendar_demo/load_chart/load_demo_page.dart';
import 'package:gantt_flutter/calendar_demo/progress_chart/progress_demo_page.dart';
import 'package:gantt_flutter/calendar_demo/info_table/resource_table_page.dart';
import 'package:gantt_flutter/calendar_demo/info_table/order_table_page.dart';
import 'package:gantt_flutter/calendar_demo/home_page/list_animation_page.dart';
import 'package:gantt_flutter/calendar_demo/home_page/PageItem.dart';

class CalendarDemoPage extends StatelessWidget {
  List<Item> _pages;

  @override
  Widget build(BuildContext context) {
    _pages = [
      Item(
        name: "Resource Gantt",
        image:
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1607595661512&di=758deeb88abcd8325808b3ad274ef6e7&imgtype=0&src=http%3A%2F%2Fpic.51yuansu.com%2Fpic2%2Fcover%2F00%2F44%2F63%2F5814b5c376355_610.jpg",
        description:
            "Shows the gantt chart for all resources in indicated day, grouped by products and each products showed in different colors.",
        page: GranttChartScreen(),
      ),
      Item(
        name: "Resource Load",
        image:
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1959883446,3062622374&fm=26&gp=0.jpg",
        description:
            "Show the load information for each resources in indicated duration, grouped by the date.",
        page: LoadDemoPage(),
      ),
      Item(
        name: "Order Progress",
        image:
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2803780353,2652913098&fm=26&gp=0.jpg",
        description:
            "Show the on-time delivery rate and orders' progress indicator in the chosen day, each orders showed indicate that it has crafts that day.",
        page: ProgressDemoPage(),
      ),
      Item(
        name: "Resource Info",
        image:
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1510094872,3558345393&fm=26&gp=0.jpg",
        description:
            "Show all the resources' information, both human kind and device kind.",
        page: ResourceTableDemoPage(),
      ),
      // Item(
      //   name: "Sub-order Info",
      //   image:
      //       "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1607595168976&di=c2f1855ff5945e0e854da3c58d93ef73&imgtype=0&src=http%3A%2F%2Fbpic.588ku.com%2Felement_origin_min_pic%2F00%2F92%2F55%2F6356f227e8860b4.jpg%2521rw400",
      //   description: "Show information for sub-orders.",
      //   page: OrderTableDemoPage(),
      // ),
    ];

    List<Widget> navigations = new List<Widget>();
    navigations.add(SizedBox(height: 40.0));

    for (int i = 0; i < _pages.length; i++) {
      navigations.add(ListTile(
          title: Text(_pages[i].name),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _pages[i].page))));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text('APS System'),
          backgroundColor: Theme.of(context).primaryColor),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: navigations),
      ),
      body: Center(
        child: ListAnimationPage(pages: _pages),
      ),
    );
  }
}
