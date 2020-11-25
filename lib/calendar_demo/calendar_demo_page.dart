import 'package:flutter/material.dart';
import 'gantt_chart/gantt_chart_screen.dart';
import 'gantt_chart/load_demo_page.dart';

//定义假数据，向子组件传参

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
                    MaterialPageRoute(builder: (context) => LoadDemoPage())))
          ],
        ),
      ),
      body: Center(
        child: Text('Tap Menu to continue'),
      ),
    );
  }
}
