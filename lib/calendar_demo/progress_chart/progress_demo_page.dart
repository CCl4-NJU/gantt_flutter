import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gantt_flutter/calendar_demo/http_data/progress_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:gantt_flutter/models.dart';

var progress_colors = [
  Colors.lightBlue,
  Colors.lime,
  Colors.orange,
  Colors.purple,
];

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class ProgressDemoPage extends StatefulWidget {
  @override
  ProgressDemoPageState createState() => ProgressDemoPageState();
}

class ProgressDemoPageState extends State<ProgressDemoPage> {
  Future<ProgressPageData> futureProgress;

  List<OrderData> _data_items;
  int _delivery_rate;
  DateTime _selected_date;

  @override
  void initState() {
    super.initState();

    _selected_date = DateTime(2017, 10, 1);
    _delivery_rate = 0;
    _data_items = <OrderData>[];

    mockProgressConfig();
    futureProgress = fetchProgressData(client, _selected_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Progress'),
      ),
      body: Center(
        child: FutureBuilder<ProgressPageData>(
          future: futureProgress,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _data_items.clear();
              _data_items.addAll(snapshot.data.orders
                  .map((item) => OrderData(
                      item.id,
                      item.crafts
                          .map((craft) =>
                              ProgressData(craft.name, craft.percent))
                          .toList(),
                      item.delay))
                  .toList());

              _delivery_rate = snapshot.data.rate;
              return _buildCharts(context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
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

        futureProgress = fetchProgressData(client, _selected_date);
      });
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
      String center_str = data.crafts[i].name +
          ': ' +
          (data.crafts[i].percent * 100).toString() +
          '%';
      progress_items.add(new LinearPercentIndicator(
        width: (MediaQuery.of(context).size.width - 200) / len,
        lineHeight: 20.0,
        animation: true,
        animationDuration: 500,
        percent: percent,
        leading: new Text(i == 0 ? ('Order ' + data.id + ': ') : ' '),
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

void mockProgressConfig() {
  String response_2017_10_01 =
      '{"orders":[{"id":"418575","delay":false},{"id":"418477","delay":true},{"id":"418480","delay":false},{"id":"418520","delay":false},{"id":"418555","delay":false},{"id":"418577","delay":false}],"crafts":[{"id":"418575","name":"Assemble","percent":0.6},{"id":"418477","name":"Assemble","percent":0.23},{"id":"418477","name":"Test","percent":0.18},{"id":"418480","name":"Assemble","percent":0.98},{"id":"418480","name":"Combine","percent":0.68},{"id":"418480","name":"Test","percent":0.08},{"id":"418520","name":"Assemble","percent":0.63},{"id":"418555","name":"Assemble","percent":0.25},{"id":"418555","name":"Test","percent":0},{"id":"418577","name":"Assemble","percent":0.78}],"rate":83}';
  String response_2017_10_02 =
      '{"orders":[{"id":"418575","delay":false},{"id":"418477","delay":true},{"id":"418480","delay":false},{"id":"418520","delay":false},{"id":"418555","delay":false},{"id":"418577","delay":false},{"id":"518034","delay":false},{"id":"523002","delay":false},{"id":"523864","delay":false}],"crafts":[{"id":"418575","name":"Assemble","percent":1},{"id":"418477","name":"Assemble","percent":0.83},{"id":"418477","name":"Test","percent":0.78},{"id":"418480","name":"Assemble","percent":1},{"id":"418480","name":"Combine","percent":1},{"id":"418480","name":"Test","percent":0.9},{"id":"418520","name":"Assemble","percent":1},{"id":"418555","name":"Assemble","percent":0.75},{"id":"418555","name":"Test","percent":0.7},{"id":"418577","name":"Assemble","percent":1},{"id":"518034","name":"Assemble","percent":0.55},{"id":"518034","name":"Test","percent":0.4},{"id":"523002","name":"Assemble","percent":0.43},{"id":"523864","name":"Assemble","percent":0.3},{"id":"523864","name":"Recheck","percent":0.1},{"id":"523864","name":"Transport","percent":0.06},{"id":"523864","name":"Test","percent":0}],"rate":88}';
  when(client.get('localhost:8080/progress/2017-10-1'))
      .thenAnswer((_) async => http.Response(response_2017_10_01, 200));
  when(client.get('localhost:8080/progress/2017-10-2'))
      .thenAnswer((_) async => http.Response(response_2017_10_02, 200));
}
