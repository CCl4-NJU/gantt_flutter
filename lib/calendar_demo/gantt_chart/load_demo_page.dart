import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'models.dart';

var bar_colors = [
  charts.ColorUtil.fromDartColor(Colors.lightBlue),
  charts.ColorUtil.fromDartColor(Colors.blueGrey),
  charts.ColorUtil.fromDartColor(Colors.lime),
  charts.ColorUtil.fromDartColor(Colors.orange),
  charts.ColorUtil.fromDartColor(Colors.purple),
  charts.ColorUtil.fromDartColor(Colors.red),
];

class LoadDemoPage extends StatefulWidget {
  @override
  LoadDemoPageState createState() => LoadDemoPageState();
}

class LoadDemoPageState extends State<LoadDemoPage> {
  var _data_rows = <RowData>[];
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
      body: Container(
        child: _buildCharts(),
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
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _data_rows.length,
      itemBuilder: (context, i) {
        return _buildRow(_data_rows[i]);
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
      colorFn: (BarLoad load, _) => bar_colors[load.load_percent ~/ 20],
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
  );
}
