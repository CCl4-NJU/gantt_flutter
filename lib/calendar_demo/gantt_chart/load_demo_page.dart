import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gantt_flutter/calendar_demo/http_data/load_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'models.dart';

var bar_colors = [
  Colors.lightBlue,
  Colors.green,
  Colors.lime,
  Colors.orange,
  Colors.purple,
  Colors.red,
];

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class LoadDemoPage extends StatefulWidget {
  @override
  LoadDemoPageState createState() => LoadDemoPageState();
}

class LoadDemoPageState extends State<LoadDemoPage> {
  Future<LoadPageData> futureLoad;

  List<RowData> _data_rows;
  int _device_load;
  int _human_load;
  DateTime _from_date;
  DateTime _to_date;

  @override
  void initState() {
    super.initState();

    _data_rows = <RowData>[];
    _device_load = 0;
    _human_load = 0;
    _from_date = DateTime(2017, 10, 1);
    _to_date = DateTime(2017, 10, 7);

    mockLoadConfig();
    futureLoad = fetchLoadData(client, _from_date, _to_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Chart'),
      ),
      body: Stack(
        children: [
          FutureBuilder<LoadPageData>(
            future: futureLoad,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _data_rows.clear();
                _data_rows.addAll(snapshot.data.rows
                    .map((item) => RowData(
                        item.date,
                        item.loads
                            .map((load) => BarLoad(load.resource, load.percent))
                            .toList()))
                    .toList());

                _human_load = snapshot.data.human;
                _device_load = snapshot.data.device;

                return _buildCharts(context);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          )
        ],
      ),
    );
  }

  Widget _buildRow(RowData data) {
    return new Container(
      height: 300,
      child: getBar(data.data, data.date),
    );
  }

  Widget _buildCharts(BuildContext context) {
    dateTimeRangePicker() async {
      DateTimeRange picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: DateTimeRange(
          end: _to_date,
          start: _from_date,
        ),
      );

      setState(() {
        _from_date = picked.start;
        _to_date = picked.end;

        _data_rows.clear();
        futureLoad = fetchLoadData(client, _from_date, _to_date);
      });
    }

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
        child: new Column(children: [
      new Text(DateFormat('yyyy-MM-dd').format(_from_date) +
          ' to ' +
          DateFormat('yyyy-MM-dd').format(_to_date)),
      RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        onPressed: () {
          dateTimeRangePicker();
        },
        child: Text("View resource load in another duration..."),
      ),
    ])));

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

void mockLoadConfig() {
  String response_2017_10_01 =
      '{"rows":[{"id":"1","date":"2017-10-01"},{"id":"2","date":"2017-10-02"},{"id":"3","date":"2017-10-03"},{"id":"4","date":"2017-10-04"},{"id":"5","date":"2017-10-05"},{"id":"6","date":"2017-10-06"},{"id":"7","date":"2017-10-07"}],"loads":[{"id":"1","resource":"Line 1","percent":13},{"id":"1","resource":"Line 2","percent":28},{"id":"1","resource":"Tang Sanzang","percent":43},{"id":"1","resource":"Sun Wukong","percent":66},{"id":"1","resource":"Zhu Bagai","percent":83},{"id":"1","resource":"Sha Wujing","percent":100},{"id":"2","resource":"Line 1","percent":23},{"id":"2","resource":"Line 2","percent":38},{"id":"2","resource":"Tang Sanzang","percent":53},{"id":"2","resource":"Sun Wukong","percent":76},{"id":"2","resource":"Zhu Bagai","percent":93},{"id":"2","resource":"Sha Wujing","percent":90},{"id":"3","resource":"Line 1","percent":33},{"id":"3","resource":"Line 2","percent":48},{"id":"3","resource":"Tang Sanzang","percent":63},{"id":"3","resource":"Sun Wukong","percent":86},{"id":"3","resource":"Zhu Bagai","percent":83},{"id":"3","resource":"Sha Wujing","percent":80},{"id":"4","resource":"Line 1","percent":43},{"id":"4","resource":"Line 2","percent":58},{"id":"4","resource":"Tang Sanzang","percent":73},{"id":"4","resource":"Sun Wukong","percent":96},{"id":"4","resource":"Zhu Bagai","percent":73},{"id":"4","resource":"Sha Wujing","percent":70},{"id":"5","resource":"Line 1","percent":53},{"id":"5","resource":"Line 2","percent":68},{"id":"5","resource":"Tang Sanzang","percent":83},{"id":"5","resource":"Sun Wukong","percent":86},{"id":"5","resource":"Zhu Bagai","percent":63},{"id":"5","resource":"Sha Wujing","percent":60},{"id":"6","resource":"Line 1","percent":66},{"id":"6","resource":"Line 2","percent":69},{"id":"7","resource":"Line 1","percent":83},{"id":"7","resource":"Line 2","percent":78}],"human":75,"device":86}';
  String response_2017_10_08 =
      '{"rows":[{"id":"1","date":"2017-10-08"},{"id":"2","date":"2017-10-09"},{"id":"3","date":"2017-10-10"},{"id":"4","date":"2017-10-11"},{"id":"5","date":"2017-10-12"},{"id":"6","date":"2017-10-13"},{"id":"7","date":"2017-10-14"}],"loads":[{"id":"1","resource":"Line 1","percent":87},{"id":"1","resource":"Line 2","percent":72},{"id":"1","resource":"Tang Sanzang","percent":57},{"id":"1","resource":"Sun Wukong","percent":34},{"id":"1","resource":"Zhu Bagai","percent":17},{"id":"1","resource":"Sha Wujing","percent":0},{"id":"2","resource":"Line 1","percent":77},{"id":"2","resource":"Line 2","percent":62},{"id":"2","resource":"Tang Sanzang","percent":47},{"id":"2","resource":"Sun Wukong","percent":24},{"id":"2","resource":"Zhu Bagai","percent":7},{"id":"2","resource":"Sha Wujing","percent":10},{"id":"3","resource":"Line 1","percent":67},{"id":"3","resource":"Line 2","percent":52},{"id":"3","resource":"Tang Sanzang","percent":37},{"id":"3","resource":"Sun Wukong","percent":14},{"id":"3","resource":"Zhu Bagai","percent":17},{"id":"3","resource":"Sha Wujing","percent":20},{"id":"4","resource":"Line 1","percent":57},{"id":"4","resource":"Line 2","percent":42},{"id":"4","resource":"Tang Sanzang","percent":27},{"id":"4","resource":"Sun Wukong","percent":4},{"id":"4","resource":"Zhu Bagai","percent":27},{"id":"4","resource":"Sha Wujing","percent":30},{"id":"5","resource":"Line 1","percent":47},{"id":"5","resource":"Line 2","percent":32},{"id":"5","resource":"Tang Sanzang","percent":17},{"id":"5","resource":"Sun Wukong","percent":14},{"id":"5","resource":"Zhu Bagai","percent":37},{"id":"5","resource":"Sha Wujing","percent":40},{"id":"6","resource":"Line 1","percent":34},{"id":"6","resource":"Line 2","percent":31},{"id":"7","resource":"Line 1","percent":17},{"id":"7","resource":"Line 2","percent":22}],"human":35,"device":14}';
  when(client.get('localhost:8080/load/2017-10-1/2017-10-7'))
      .thenAnswer((_) async => http.Response(response_2017_10_01, 200));
  when(client.get('localhost:8080/load/2017-10-8/2017-10-14'))
      .thenAnswer((_) async => http.Response(response_2017_10_08, 200));
}
