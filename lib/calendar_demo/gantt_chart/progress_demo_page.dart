import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'models.dart';
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

    _delivery_rate = 90;
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
        'On-time delivery rate：Till 2017-10-01',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
    ));

    listViews.add(new Center(
      child: new Column(
        children: [
          FlatButton(
              onPressed: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(2017, 1, 1),
                    maxTime: DateTime(2026, 12, 31),
                    theme: DatePickerTheme(
                        headerColor: Colors.blue,
                        backgroundColor: Colors.white,
                        itemStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        doneStyle:
                            TextStyle(color: Colors.black, fontSize: 16)),
                    onConfirm: (date) {
                  print('confirm $date');
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Text(
                'See information in another date...',
                style: TextStyle(color: Colors.blue),
              ))
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
}
