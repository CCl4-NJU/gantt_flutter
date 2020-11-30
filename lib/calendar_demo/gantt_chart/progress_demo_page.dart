import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'models.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
  var _delivery_rate = 0;
  DateTime _selected_date = DateTime(2017, 10, 1);

  int _mock_index = 0;

  @override
  void initState() {
    super.initState();
    /** 以下是硬编码假数据 */
    getProgressData();
    /** 硬编码假数据结束 */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Progress'),
      ),
      body: Center(
        child: _buildCharts(context),
      ),
    );
  }

  Widget _buildCharts(BuildContext context) {
    datePicker() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selected_date,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
      );
      setState(() {
        _selected_date = picked;

        _mock_index = 1 - _mock_index;
        _data_items.clear();
        _data_items.addAll(order_arr[_mock_index]);
        _delivery_rate = rate_arr[_mock_index];
      });

      //TODO:Change progress data
      print(picked);
    }

    List<Widget> listViews = <Widget>[];

    listViews.add(new CircularPercentIndicator(
      radius: 130.0,
      animation: true,
      animationDuration: 1200,
      lineWidth: 15.0,
      percent: _delivery_rate / 100,
      center: new Text(
        _delivery_rate.toString() + '%',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      progressColor: _delivery_rate < 20
          ? Colors.red
          : progress_colors[4 - (_delivery_rate ~/ 20)],
      footer: new Text(
        'On-time delivery rate：Till ' +
            DateFormat('yyyy-MM-dd').format(_selected_date),
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
    ));

    listViews.add(new Center(
      child: new Column(
        children: [
          RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              datePicker();
            },
            child: Text("View order progress in another date..."),
          ),
        ],
      ),
    ));

    for (int i = 0; i < _data_items.length; i++) {
      listViews.add(_buildRow(_data_items[i]));
    }

    return new ListView.builder(
      itemCount: listViews.length,
      itemBuilder: (context, i) {
        return listViews[i];
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

  getProgressData() {
    _data_items.addAll(orders);

    _delivery_rate = rate;
  }
}

var orders = [
  new OrderData(
      '418575',
      [
        new ProgressData('装配', 1),
      ],
      false),
  new OrderData(
      '418577',
      [
        new ProgressData('装配', 1),
      ],
      false),
  new OrderData(
      '764486',
      [
        new ProgressData('装配', 0.6),
      ],
      true),
  new OrderData(
      '762904',
      [
        new ProgressData('装配', 0.23),
        new ProgressData('测试', 0.18),
      ],
      false),
  new OrderData(
      '418477',
      [
        new ProgressData('装配', 0.23),
        new ProgressData('测试', 0),
      ],
      false),
  new OrderData(
      '418006',
      [
        new ProgressData('装配', 0.20),
        new ProgressData('测试', 0.18),
      ],
      true),
];
var orders2 = [
  new OrderData(
      '318575',
      [
        new ProgressData('装配', 1),
      ],
      false),
  new OrderData(
      '318577',
      [
        new ProgressData('装配', 0.8),
      ],
      false),
  new OrderData(
      '864486',
      [
        new ProgressData('装配', 0.6),
        new ProgressData('测试', 0.4),
        new ProgressData('抽样', 0.2),
      ],
      false),
  new OrderData(
      '862904',
      [
        new ProgressData('装配', 0.23),
        new ProgressData('测试', 0.18),
        new ProgressData('质检', 0),
      ],
      false),
  new OrderData(
      '318477',
      [
        new ProgressData('装配', 0.23),
        new ProgressData('测试', 0),
      ],
      false),
  new OrderData(
      '318006',
      [
        new ProgressData('装配', 0.20),
        new ProgressData('测试', 0.18),
        new ProgressData('组合', 0.1),
        new ProgressData('质检', 0),
      ],
      true),
  new OrderData(
      '218006',
      [
        new ProgressData('装配', 0.90),
        new ProgressData('测试', 0.88),
        new ProgressData('组合', 0.81),
        new ProgressData('质检', 0.75),
      ],
      false),
  new OrderData(
      '218007',
      [
        new ProgressData('装配', 0.90),
        new ProgressData('测试', 0.78),
        new ProgressData('质检', 0.65),
      ],
      false),
  new OrderData(
      '218008',
      [
        new ProgressData('装配', 0.90),
      ],
      false),
  new OrderData(
      '218009',
      [
        new ProgressData('装配', 1),
      ],
      false),
  new OrderData(
      '218010',
      [
        new ProgressData('装配', 0.1),
        new ProgressData('测试', 0.95),
      ],
      false),
];

var rate = 67;
var rate2 = 91;

var order_arr = [orders, orders2];
var rate_arr = [rate, rate2];
