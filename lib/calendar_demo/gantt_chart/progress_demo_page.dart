import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  final _data_items = <OrderData>[];

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
        title: Text('Load Chart'),
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

class OrderData {
  String id; //订单号
  List<ProgressData> crafts; //工艺信息
  bool delay; //是否延期
  String deal; //约定交期
  String expc; //预计交期
  OrderData(this.id, this.crafts, this.delay);
}

class ProgressData {
  String name; //工艺
  double percent;
  ProgressData(this.name, this.percent);
}
