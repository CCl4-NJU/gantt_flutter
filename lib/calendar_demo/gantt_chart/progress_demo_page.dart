import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'models.dart';

var progress_colors = [
  Colors.lightBlue,
  Colors.lime,
  Colors.orange,
  Colors.purple,
];

class ProgressDemoPage extends StatefulWidget {
  @override
  ProgressDemoPageState createState() => ProgressDemoPageState();
}

class ProgressDemoPageState extends State<ProgressDemoPage> {
  var _data_items = <OrderData>[];

  @override
  void initState() {
    super.initState();
    /** 以下是硬编码假数据 */
    _data_items.add(new OrderData(
        '418575',
        [
          new ProgressData('装配', 1),
        ],
        false));
    _data_items.add(new OrderData(
        '418577',
        [
          new ProgressData('装配', 1),
        ],
        false));
    _data_items.add(new OrderData(
        '764486',
        [
          new ProgressData('装配', 0.6),
        ],
        true));
    _data_items.add(new OrderData(
        '762904',
        [
          new ProgressData('装配', 0.23),
          new ProgressData('测试', 0.18),
        ],
        false));
    _data_items.add(new OrderData(
        '418477',
        [
          new ProgressData('装配', 0.23),
          new ProgressData('测试', 0),
        ],
        false));
    _data_items.add(new OrderData(
        '418006',
        [
          new ProgressData('装配', 0.20),
          new ProgressData('测试', 0.18),
        ],
        true));
    /** 硬编码假数据结束 */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Progress'),
      ),
      body: Center(
        child: _buildCharts(),
      ),
    );
  }

  Widget _buildCharts() {
    return new ListView.builder(
      itemCount: _data_items.length,
      itemBuilder: (context, i) {
        return _buildRow(_data_items[i]);
      },
    );
  }

  Widget _buildRow(OrderData data) {
    List<Widget> progress_items = [];
    Widget content;
    int len = data.crafts.length;
    for (int i = 0; i < len; i++) {
      double percent = data.crafts[i].percent;
      String center_str =
          data.crafts[i].name + (data.crafts[i].percent * 100).toString() + '%';
      progress_items.add(new LinearPercentIndicator(
        width: (MediaQuery.of(context).size.width - 200) / len,
        lineHeight: 20.0,
        animation: true,
        animationDuration: 500,
        percent: percent,
        leading: new Text(i == 0 ? ('订单' + data.id + ': ') : ' '),
        center: Text(center_str),
        progressColor: data.delay
            ? Colors.red
            : (percent >= 1
                ? Colors.green
                : progress_colors[i % progress_colors.length]),
        linearStrokeCap: LinearStrokeCap.roundAll,
      ));
    }
    content = new Row(
      children: progress_items,
    );
    return new Padding(
      padding: EdgeInsets.all(16.0),
      child: content,
    );
  }
}
