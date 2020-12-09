import 'package:flutter/material.dart';
import 'package:gantt_flutter/calendar_demo/gantt_chart/gantt_chart_screen.dart';
import 'package:gantt_flutter/calendar_demo/load_chart/load_demo_page.dart';
import 'package:gantt_flutter/calendar_demo/progress_chart/progress_demo_page.dart';
import 'package:gantt_flutter/calendar_demo/info_table/resource_table_page.dart';
import 'package:gantt_flutter/calendar_demo/info_table/order_table_page.dart';

class CalendarDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 40.0),
            ListTile(
                title: Text('Resource Gantt'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GranttChartScreen()))),
            ListTile(
                title: Text('Resource Load'),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoadDemoPage()))),
            ListTile(
                title: Text('Order Progress'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProgressDemoPage()))),
            ListTile(
                title: Text('Resource Info'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ResourceTableDemoPage()))),
            ListTile(
                title: Text('Order Info'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OrderTableDemoPage()))),
          ],
        ),
      ),
      body: Center(
        child: Text('Tap Menu to continue'),
      ),
    );
  }
}
