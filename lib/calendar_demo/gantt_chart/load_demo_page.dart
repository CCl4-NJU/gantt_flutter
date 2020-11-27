import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:percent_indicator/percent_indicator.dart';

import 'models.dart';

var bar_colors = [
  Colors.lightBlue,
  Colors.green,
  Colors.lime,
  Colors.orange,
  Colors.purple,
  Colors.red,
];

class LoadDemoPage extends StatefulWidget {
  @override
  LoadDemoPageState createState() => LoadDemoPageState();
}

class LoadDemoPageState extends State<LoadDemoPage> {
  final _data_rows = <RowData>[];
  int _device_load = 0;
  int _human_load = 0;

  @override
  void initState() {
    super.initState();
    /** 以下是硬编码假数据 */
    _data_rows.add(new RowData('2017-10-01', [
      new BarLoad('Line 1', 23),
      new BarLoad('Line 2', 78),
      new BarLoad('张三', 23),
      new BarLoad('李四', 76),
      new BarLoad('张扬', 23),
      new BarLoad('李彤', 76),
    ]));
    _data_rows.add(new RowData('2017-10-02', [
      new BarLoad('Line 1', 50),
      new BarLoad('Line 2', 113),
      new BarLoad('张三', 50),
      new BarLoad('李四', 99),
      new BarLoad('张扬', 50),
      new BarLoad('李彤', 99),
    ]));
    _data_rows.add(new RowData('2017-10-03', [
      new BarLoad('Line 1', 68),
      new BarLoad('Line 2', 23),
      new BarLoad('张三', 58),
      new BarLoad('李四', 50),
      new BarLoad('张扬', 58),
      new BarLoad('李彤', 50),
    ]));
    _data_rows.add(new RowData('2017-10-04', [
      new BarLoad('Line 1', 99),
      new BarLoad('Line 2', 58),
      new BarLoad('张三', 50),
      new BarLoad('李四', 99),
      new BarLoad('张扬', 50),
      new BarLoad('李彤', 99),
    ]));
    _data_rows.add(new RowData('2017-10-05', [
      new BarLoad('Line 1', 50),
      new BarLoad('Line 2', 113),
      new BarLoad('张三', 50),
      new BarLoad('李四', 99),
      new BarLoad('张扬', 50),
      new BarLoad('李彤', 99),
    ]));

    _device_load = 75;
    _human_load = 66;
    /** 硬编码假数据结束 */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Chart'),
      ),
      body: Stack(
        children: [_buildCharts()],
      ),
    );
  }

  Widget _buildRow(RowData data) {
    return new Container(
      height: 300,
      child: getBar(data.data, data.date),
    );
  }

  Widget _buildCharts() {
    List<Widget> listViews = <Widget>[];

    //在此处添加设备占用率
    var data = [_device_load, _human_load];
    var text = ['Device Load', 'Human Load'];
    List<Widget> load_sum_items = [];
    Widget content;

    for (int i = 0; i < 2; i++) {
      double percent = data[i] / 100.0;

      load_sum_items.add(new CircularPercentIndicator(
        radius: MediaQuery.of(context).size.width / 12,
        lineWidth: (MediaQuery.of(context).size.width ~/ 540) * 4.0,
        percent: data[i] / 100.0,
        center: new Text(data[i].toString() + '%'),
        progressColor: bar_colors[data[i] ~/ 20],
        footer: new Text(
          text[i],
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
        ),
      ));

      if (i == 0) {
        load_sum_items.add(new Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 15),
        ));
      }
    }

    content = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: load_sum_items,
    );

    listViews.add(new Container(
      padding: EdgeInsets.all(15.0),
      child: content,
    ));

    listViews.add(new Center(
      child: new Text('2017-10-01 to 2017-10-05'),
    ));

    for (int i = 0; i < _data_rows.length; i++) {
      listViews.add(_buildRow(_data_rows[i]));
    }

    return new ListView.builder(
      padding: const EdgeInsets.all(30.0),
      itemCount: listViews.length,
      itemBuilder: (context, i) {
        return listViews[i];
      },
    );
  }
}

Widget getBar(List<BarLoad> dataBar, String date) {
  var seriesBar = [
    charts.Series(
      data: dataBar,
      domainFn: (BarLoad load, _) => load.resource,
      measureFn: (BarLoad load, _) => load.load_percent,
      colorFn: (BarLoad load, _) =>
          charts.ColorUtil.fromDartColor(bar_colors[load.load_percent ~/ 20]),
      labelAccessorFn: (BarLoad load, _) =>
          (load.load_percent.toString() + '%'),
      id: 'Load',
    )
  ];
  return charts.BarChart(
    seriesBar,
    animate: true,
    behaviors: [
      new charts.ChartTitle(date,
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleOutsideJustification:
              charts.OutsideJustification.middleDrawArea),
    ],
    barRendererDecorator: new charts.BarLabelDecorator<String>(),
  );
}
